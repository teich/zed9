require 'hpricot'

class WorkoutsController < ApplicationController
	helper_method :my_workout?, :my_workouts?
	before_filter :require_user, :except => [:show, :index]

	before_filter :find_workout, :only => [:edit, :update, :destroy, :merge]
	before_filter :find_and_bounce, :only => [:show]
	before_filter :find_user_and_require_shared, :only => [:index]
	before_filter :upload_if_no_workouts, :only => [:index]
	after_filter  :check_achievements
	
	def index

		# TODO: DRY
		if my_workouts?
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
			@workout = current_user.workouts.create!(params[:workout])
			if @workout.devices.first.nil?
				@workout.destroy
				add_flash(:alert, "Please select a file to upload")
				add_flash(:alert, "Testing an alert")
				redirect_to :action => "new", :device_type => params[:device_type]
			else
				# This line may need to be changed for S3...
				uploaded_data = ensure_string(@workout.devices.first.source.to_file)
		
				importer = Importer::Garmin.new(:data => uploaded_data) if params[:device_type] == "garmin"
				importer = Importer::Polar.new(:data => uploaded_data, :time_zone => current_user.time_zone) if params[:device_type] == "polar"
				importer = Importer::Suunto.new(:data => uploaded_data, :time_zone => current_user.time_zone) if params[:device_type] == "suunto"
				importer = Importer::GPX.new(:data => uploaded_data) if params[:device_type] == "gpx"

				iw = importer.restore
				@workout.build_from_imported!(iw)


				overlap = @workout.overlap?(current_user)

				if @workout.save
					add_flash(:notice, 'Workout added!')
					if overlap.size > 0
						redirect_to workout_overlaps_path(@workout)
					else
						redirect_to @workout
					end
				else
					add_flash(:notice, "Unable to save workout for some lame reason.")
					render :action => "new"
				end
			end
	end


	def update
		if @workout.update_attributes(params[:workout])
			add_flash(:notice, 'Workout updated.')
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
			add_flash(:notice, "This workout is private")
			redirect_to root_path 
		end
	end

	def ensure_string(uploaded_file)
		uploaded_file.is_a?(String) ? uploaded_file : uploaded_file.read
	end

	def find_user_and_require_shared
		@user = User.find_by_login(params[:user_id])

		if !(!current_user.nil? && current_user.id == @user.id) && !@user.shared
		  add_flash(:notice, "This page is private")
			redirect_to root_path
		end
	end

	def my_workout?
		if logged_in? 
			return (@workout.user_id == current_user.id)
		else 
			return false
		end
	end

	def my_workouts?
		if logged_in?
			return @user == current_user
		else
			return false
		end
	end
  
  def upload_if_no_workouts
    redirect_to new_user_workout_path(current_user) if my_workouts? && current_user.workouts.size == 0 
  end

	
	def check_achievements
		achievements = Achievement.find(:all, :conditions => ['controller = ? AND action = ?', params[:controller], params[:action]])
		achievements.each do |a|
			if eval a.logic and !@workout.user.awarded?(a)
				@workout.user.award(a)
				add_flash(:notice, "Congratulations!  You've just recieved a new achievement - #{a.name}")
			end
		end
	end
end
