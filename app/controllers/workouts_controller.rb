require 'hpricot'

class WorkoutsController < ApplicationController
  before_filter :require_user
  
  before_filter :find_workout, :only => [:show, :edit, :update, :destroy]
  
  def index
    if params[:tag]
      @workouts = current_user.workouts.find_tagged_with(params[:tag])
    else
      @workouts = current_user.workouts.find(:all, :order => "start_time DESC")
    end
  end

  def show
  end

  def new
    @workout = current_user.workouts.build
  end

  def edit
  end

  def create
    @workout = current_user.workouts.build(params[:workout])

    uploaded_file = params[:device_file] 
    if request.post? and uploaded_file.respond_to? :read
      
      # Version I'm running here seems to pass as string is <10K, or file if over.
      uploaded_data = ensure_string(uploaded_file)
      
      parsed_data = @workout.parse_polar( uploaded_data ) if is_polar?(params[:device])
      parsed_data = @workout.parse_garmin_xml( uploaded_data ) if is_garmin?(params[:device])

      @workout.update_attributes(:start_time => parsed_data["start_time"], :duration => parsed_data["duration"] )

      points = parsed_data["datapoints"]
      points.each { |p| @workout.trackpoints.build(p) }
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
