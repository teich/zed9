require 'hpricot'

class WorkoutsController < ApplicationController
  helper_method :my_workout?  
  before_filter :require_user, :except => [:show]
  
  before_filter :find_workout, :only => [:edit, :update, :destroy]
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
    @comps = @workout.find_comps(@workout.user)

    # need for creating new tags.  
    @tagging = Tagging.new
    
    if @workout.gps_data? 
      @map = GMap.new("map_div")
      @map.control_init(:large_map => true,:map_type => true)
      start = [@workout.trackpoints[0].lat, @workout.trackpoints[0].lng]
      points = @workout.trackpoints.map { |tp| [tp.lat, tp.lng] }
      polyline = GPolyline.new(points,"#a000f0",3,1.0)
      @map.overlay_init(polyline)
      @map.center_zoom_init(start,13)
      @map.overlay_init(GMarker.new(start,:title => "Hello", :info_window => "Starting Point"))
    end
    
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @workout.to_xml }
      format.js {render :js => @workout.to_json(:methods => [:json_heartrate, :json_speed, :json_elevation])}
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
      
      # Version I'm running here seems to pass as string is <10K, or file if over.
      uploaded_data = ensure_string(uploaded_file)
      importer = GarminImporter.new(uploaded_data, params[:workout]) if is_garmin?(params[:device_type])
      importer = PolarImporter.new(uploaded_data, params[:workout], current_user.time_zone) if is_polar?(params[:device_type])
      
      @workout = current_user.workouts.build(importer.get_workout)
      
      trackpoints = importer.get_trackpoints
      time_one = Time.parse(trackpoints.first["time"])
      distance_one = trackpoints.first["distance"].to_f
      
      trackpoints.each do |tp|
        
        ## Calculate speed
        distance_two = tp["distance"].to_f
        time_two = Time.parse(tp["time"])
        time_delta = time_two - time_one
        distance_delta = distance_two - distance_one
        if (distance_delta > 0 && time_delta > 0)
          tp["speed"] = distance_delta / time_delta
          distance_one = distance_two
          time_one = time_two
        else tp["speed"] = nil
        end
        
        ## Calculate altitude
        
        ## Calculate average speed
        
        ## Store the trackpoint
        @workout.trackpoints.build(tp)
      end
      
      ## Set some workout variables that require trackpoint analysis.
      @workout.distance = trackpoints.last["distance"] if !trackpoints.last["distance"].nil?
      @workout.avg_speed = @workout.calc_average_speed
      @workout.elevation_gain = @workout.calc_elevation_gain
      @workout.average_hr = @workout.calc_avg_hr if @workout.average_hr.nil?
    end
    
    if @workout.save
      flash[:notice] = 'Workout was successfully created.'
      redirect_to @workout
    else
      flash[:notice] = "can't save workout for some lame reason."
      render :action => "new"
    end
  end


  def update
    if @workout.update_attributes(params[:workout])
      flash[:notice] = 'Workout was successfully updated.'
      redirect_to @workout
    else
      render :action => "edit"
    end
  end


  def destroy
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
      flash[:notice] = "The workout you tried to view is not public"
      redirect_to root_path 
    end
  end

  def is_garmin?(device)
    device == "garmin"
  end
    
  def is_polar?(device)
    device == "polar"
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
