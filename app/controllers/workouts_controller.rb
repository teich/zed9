require 'hpricot'

class WorkoutsController < ApplicationController
	helper_method :my_workout?  
	before_filter :require_user, :except => [:show]

	before_filter :find_workout, :only => [:edit, :update, :destroy, :merge]
	before_filter :find_and_bounce, :only => [:show]

	def index
		if params[:tag]
			@workouts = current_user.workouts.find_tagged_with(params[:tag])
		else
			@workouts = current_user.workouts.find(:all, :order => "start_time DESC")
		end

		respond_to do |format|
			format.html
			format.xml {render :xml => @workouts.to_xml }
		end
	end

	def show
		#    @comps = @workout.find_comps(@workout.user)

		# need for creating new tags.  
		@tagging = Tagging.new

		if @workout.gps_data? 
			@map = GMap.new("map_div")
			@map.control_init(:large_map => true,:map_type => true)
			start = @workout.first_gps
			points = @workout.gis
			less_points = points.compact.in_groups_of(50).map {|tp| tp[0]}
			polyline = GPolyline.new(points,"#a000f0",3,1.0)
			@map.overlay_init(polyline)
			@map.center_zoom_on_points_init(*less_points)
			@map.overlay_init(GMarker.new(start,:title => "Hello", :info_window => "Starting Point"))
		end


		respond_to do |format|
			format.html
			format.xml {render :xml => @workout.to_xml }
			format.js {render :js => @workout.to_json(:methods => [:json_hr, :json_heartrate_big, :json_speed, :json_speed_big, :json_elevation, :json_elevation_big, :json_comps, :activity_name])}
		end
	end

	def new
		@workout = current_user.workouts.build

		# Set the workout shared state to the user default
		@workout.shared = current_user.shared
	end

	def edit
	end

	def create
		uploaded_file = params[:device_file] 
		if request.post? and uploaded_file.respond_to? :read

			# Rails "optimizes" by passing a string or a Tempfile.  Always get string
			uploaded_data = ensure_string(uploaded_file)
			importer = Importer::Garmin.new(:data => uploaded_data) if params[:device_type] == "garmin"
			importer = Importer::Polar.new(:data => uploaded_data, :time_zone => current_user.time_zone) if params[:device_type] == "polar"
			importer = Importer::Suunto.new(:data => uploaded_data, :time_zone => current_user.time_zone) if params[:device_type] == "suunto"
			importer = Importer::GPX.new(:data => uploaded_data) if params[:device_type] == "gpx"


			iw = importer.restore
			@workout = current_user.workouts.build(params[:workout])
			@workout.build_from_imported!(iw)
			@workout.shared = current_user.shared

		end

		overlap = @workout.overlap?(current_user)
		# overlap_string = overlap.join(',')
		# 		logger.debug "OVERLAP:- #{overlap.nil?}"

		if @workout.save
			flash[:notice] = 'Workout added!'
			if overlap.size > 0
				redirect_to workout_overlaps_path(@workout)
			else
				redirect_to @workout
			end
		else
			flash[:notice] = "Unable to save workout for some lame reason."
			render :action => "new"
		end
	end


	def update
		if @workout.update_attributes(params[:workout])
			flash[:notice] = 'Workout updated.'
			redirect_to @workout
		else
			render :action => "edit"
		end
	end


	def destroy
		# Destroying here so that the merge can call .destroy on a workout
		@workout.trackpoints.each { |tp| tp.destroy }
		@workout.destroy
		redirect_to(user_workouts_url(current_user))
	end

	def merge
		overlap = params[:overlap].split(/,/)
		@overlap = current_user.workouts.find(overlap)
		
	end

	private

	def find_workout
		@workout = current_user.workouts.find(params[:id])
	end    

	def find_and_bounce
		@workout = Workout.find(params[:id])

		if (!@workout.shared && !current_user.nil? && (@workout.user_id != current_user.id))
			flash[:notice] = "This workout is private"
			redirect_to root_path 
		end
	end

	def ensure_string(uploaded_file)
		(uploaded_file.is_a?(String)) ? uploaded_file : uploaded_file.read
	end

	def my_workout?
		if logged_in? 
			return (@workout.user_id == current_user.id)
		else 
			return false
		end

	end
end
