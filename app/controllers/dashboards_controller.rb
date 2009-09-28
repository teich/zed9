class DashboardsController < ApplicationController
	before_filter :require_user

	def show

    if current_user.gear_expiring?
      add_flash(:warning, "Your gear has less than 20% life remaining.")
    end

		@current_weight = current_user.weight(Time.now)
    @gears = current_user.gears.find(:all, :order => "purchase_date DESC")

		@workouts = Workout.processed.find_all_by_shared(true, :order => "created_at DESC")
    @comments = Comment.find(:all, :order => "created_at DESC")
    entries = @workouts + @comments
    @activity_feed = entries.sort { |a,b| b.created_at <=> a.created_at } .paginate :page => params[:page], :per_page => 10
    
    # recent achievements
    @accomplishments = Accomplishment.find_all_by_user_id(current_user, :conditions => ['created_at > ?', 7.days.ago])
    
		@farthest = current_user.workouts.find(:all, :conditions => ['distance > ?', 0], :order => "distance DESC", :limit => 5)
		@fastest = current_user.workouts.find(:all, :conditions => ['speed > ?', 0], :order => "speed DESC", :limit => 5)
		@longest = current_user.workouts.find(:all, :conditions => ['duration > ?', 0], :order => "duration DESC", :limit => 5)
		@climbers = current_user.workouts.find(:all, :conditions => ['elevation > ?', 0], :order => "elevation DESC", :limit => 5)
		@heart_pumping = current_user.workouts.find(:all, :conditions => ['hr > ?', 0], :order => "hr DESC", :limit => 5)

    @my_workouts = current_user.workouts.processed
    durations = @my_workouts.map { |w| w.duration }
		if durations.nil?
			@my_total_time = 0
		else
			@my_total_time = durations.compact.asum
		end

		# TODO: pull out of controller!
		# figure out how much time users spend on average working out.  ick.
		users = User.find(:all)
		aud = users.map do |u|
			uw = u.workouts.find(:all)
			uwd = uw.map { |uwm| uwm.duration }
			if uwd.nil?
				utt = 0
			else
				utt = uwd.compact.asum
			end
		end 
		@atd = aud.aaverage

		respond_to do |format|
			format.html
      # format.js {render :json => current_user.json_weights.to_json }

      format.js {render :json => current_user.to_json(:include => { :workouts =>  { :methods => [:json_date, :activity_name], :except => :trackpoints } }, :except => [:single_access_token, :perishable_token, :password_salt, :persistence_token, :crypted_password], :methods => [:json_hours_per_week, :json_workouts_per_week, :json_weeks_labels, :json_weights])} 
		end
	end
end
