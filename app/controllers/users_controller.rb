class UsersController < ApplicationController

	before_filter :require_no_user, :only => [:new, :create]
	before_filter :require_user, :only => [:edit, :update]

	def new
		@user = User.new(:invitation_token => params[:invitation_token])
		@user.email = @user.invitation.recipient_email if @user.invitation
	end

	def create
		@user = User.new(params[:user])
		if @user.save
			add_flash(:notice, "Thanks for setting up your account!")
			add_flash(:info, "Upload your first workout today to move up to Novice!")
			redirect_to new_user_workout_path(@user)
		else
			render :action => :new
		end
	end

	def show
		@user = User.find_by_login(params[:id])

		@workouts = @user.workouts.processed.find_all_by_shared(true, :order => "created_at DESC")
    @comments = @user.comments
    entries = @workouts + @comments
    @activity_feed = entries.sort { |a,b| b.created_at <=> a.created_at } .paginate :page => params[:page], :per_page => 10

		# list of most recent workouts
		if my_page?
      @workouts = @user.workouts.processed.paginate :page => params[:page], :per_page => 10
      
	  else
		  @workouts = @user.workouts.processed.find_all_by_shared(true, :order => "created_at DESC").paginate :page => params[:page], :per_page => 10
	  end

    @accomplishments = Accomplishment.find_all_by_user_id(@user, :order => "created_at DESC")

    @my_workouts = @user.workouts.processed
		durations = @my_workouts.map { |w| w.duration }
		if durations.nil?
			@my_total_time = 0
		else
			@my_total_time = durations.compact.asum
		end

		@farthest = @user.workouts.find(:all, :conditions => ['distance > ?', 0], :order => "distance DESC", :limit => 5)
		@fastest = @user.workouts.find(:all, :conditions => ['speed > ?', 0], :order => "speed DESC", :limit => 5)
		@longest = @user.workouts.find(:all, :conditions => ['duration > ?', 0], :order => "duration DESC", :limit => 5)
		@climbers = @user.workouts.find(:all, :conditions => ['elevation > ?', 0], :order => "elevation DESC", :limit => 5)
		@heart_pumping = @user.workouts.find(:all, :conditions => ['hr > ?', 0], :order => "hr DESC", :limit => 5)

		@farthest_public = @user.workouts.find_all_by_shared(true, :conditions => ['distance > ?', 0], :order => "distance DESC", :limit => 5)
		@fastest_public = @user.workouts.find_all_by_shared(true, :conditions => ['speed > ?', 0], :order => "speed DESC", :limit => 5)
		@longest_public = @user.workouts.find_all_by_shared(true, :conditions => ['duration > ?', 0], :order => "duration DESC", :limit => 5)
		@climbers_public = @user.workouts.find_all_by_shared(true, :conditions => ['elevation > ?', 0], :order => "elevation DESC", :limit => 5)
		@heart_pumping_public = @user.workouts.find_all_by_shared(true, :conditions => ['hr > ?', 0], :order => "hr DESC", :limit => 5)

	end

	def edit
		@user = @current_user
	end

	def update
		@user = @current_user # makes our views "cleaner" and more consistent
		if @user.update_attributes(params[:user])
			add_flash(:notice, "Account updated")
			redirect_to @user
		else
			render :action => :edit
		end
	end
end
