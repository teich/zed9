require 'hpricot'
require 'lib/WorkoutImporter'

class WorkoutsController < ApplicationController
  before_filter :require_user
  
  before_filter :find_workout, :only => [:show, :edit, :update, :destroy]
  
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
    # TODO - ruby way of array asignment, and get out of controller
    foo = @workout.find_comps(current_user)
    @my_comps = foo[0]
    @all_comps = foo[1]
    @tagging = Tagging.new
    
    # MAP TEST
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    points = @workout.trackpoints.map { |tp| [tp.lat, tp.lng] }
    polyline = GPolyline.new(points,"#a000f0",3,1.0)
    start = [@workout.trackpoints[0].lat, @workout.trackpoints[0].lng]
    @map.overlay_init(polyline)
    @map.center_zoom_init(start,13)
    @map.overlay_init(GMarker.new(start,:title => "Hello", :info_window => "Starting Point"))
    
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @workout.to_xml }
    end
  end

  def new
    @workout = current_user.workouts.build
  end

  def edit
  end

  def create
    #@workout = current_user.workouts.build(params[:workout])

    uploaded_file = params[:device_file] 
    if request.post? and uploaded_file.respond_to? :read
      
      # Version I'm running here seems to pass as string is <10K, or file if over.
      uploaded_data = ensure_string(uploaded_file)
      importer = GarminImporter.new(uploaded_data, params[:workout]) if is_garmin?(params[:device_type])
      importer = PolarImporter.new(uploaded_data, params[:workout], current_user.time_zone) if is_polar?(params[:device_type])
      
      @workout = current_user.workouts.build(importer.get_workout)
      importer.get_trackpoints.each { |tp| @workout.trackpoints.build(tp)}
      
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
    redirect_to(workouts_url)
  end

  private

  def find_workout
    @workout = current_user.workouts.find(params[:id])
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
end
