require 'hpricot'

class WorkoutsController < ApplicationController
	before_filter :require_user, :except => [:show, :index]

	before_filter :find_workout, :only => [:edit, :update, :destroy, :merge]
	before_filter :find_and_bounce, :only => [:show]
	before_filter :find_user_and_require_shared, :only => [:index]
	before_filter :upload_if_no_workouts, :only => [:index]
	
	def index

		# TODO: DRY
		if my_page?
			if params[:tag]
				@workouts = @user.workouts.find_tagged_with(params[:tag])
			else
				@workouts = @user.workouts.find(:all, :order => "start_time DESC")
			end
			  	  
		else
			if params[:tag]
				@workouts = @user.workouts.find_tagged_with(params[:tag])
			else
				@workouts = @user.workouts.find_all_by_shared(true, :order => "start_time DESC")
			end

		end

		respond_to do |format|
			format.html
			format.xml {render :xml => @workouts.to_xml }
		end

	end

	def show
		# need for creating new tags.  
		@tagging = Tagging.new

		respond_to do |format|
			format.html
			format.xml {render :xml => @workout.to_xml }
			format.js {render :js => @workout.to_json(:methods => [:json_hr, :json_heartrate_big, :json_speed, :json_speed_big, :json_elevation, :json_elevation_big, :json_comps,:gis], :include => :activity)}
		end
	end

	def new
		@workout = current_user.workouts.build
		@workout.activity = Activity.find_by_name("Uncategorized")

		# Set the workout shared state to the user default
		@workout.shared = current_user.shared
		# setup one device for form.
		@workout.devices.build
	end

	def edit
	end

  def create
    @workout = current_user.workouts.create(params[:workout])
    @workout.importing = true
    if @workout.devices.first.nil?
      @workout.destroy
      add_flash(:alert, "Please select a file to upload")
      redirect_to :action => "new", :device_type => params[:device_type]
    else
      if @workout.save
        Delayed::Job.enqueue WorkoutJob.new(@workout.id)
        add_flash(:notice, 'Now processing your workout data... This may take up to a minute.')
        redirect_to user_workouts_path(current_user)
      else
        add_flash(:alert, "Unable to save workout for some lame reason")
        render :action => "new"
      end
    end
  end


	def update
		if @workout.update_attributes(params[:workout])
			add_flash(:notice, 'Workout updated')
			redirect_to @workout
		else
			render :action => "edit"
		end
	end


	def destroy
		# Destroying here so that the merge can call .destroy on a workout
		@workout.trackpoints.each { |tp| tp.destroy }
		@workout.devices.each { |d| d.destroy }
		@workout.destroy
		redirect_to(user_workouts_url(current_user))
	end

	private

	def find_workout
		@workout = current_user.workouts.find(params[:id])
	end    

	def find_and_bounce
		@workout = Workout.find(params[:id])

		if (!@workout.shared && !current_user.nil? && (@workout.user_id != current_user.id))
			add_flash(:alert, "This workout is private")
			redirect_to root_path 
		end
	end

	def find_user_and_require_shared
		@user = User.find_by_login(params[:user_id])

		if !(!current_user.nil? && current_user.id == @user.id) && !@user.shared
		  add_flash(:alert, "This page is private")
			redirect_to root_path
		end
	end

  # def my_workouts?
  #   if logged_in?
  #     return @user == current_user
  #   else
  #     return false
  #   end
  # end
  
  def upload_if_no_workouts
    redirect_to new_user_workout_path(current_user) if my_page? && current_user.workouts.size == 0 
  end
  
end
