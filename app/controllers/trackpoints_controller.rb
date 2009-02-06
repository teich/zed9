class TrackpointsController < ApplicationController
  def index
    @workout = Workout.find(params[:workout_id])
    @trackpoints = @workout.trackpoints
  end

  def show
    @workout = Workout.find(params[:workout_id])
    @trackpoint = Trackpoint.find(params[:id])
  end

  def new
    @workout = Workout.find(params[:workout_id])
    @trackpoint = @workout.trackpoints.build
  end

  def edit
    @workout = Workout.find(params[:workout_id])
    @trackpoint = Trackpoint.find(params[:id])
  end

  def create
    @workout = Workout.find(params[:workout_id])
    @trackpoint = @workout.trackpoints.build(params[:trackpoint])
    if @trackpoint.save
      redirect_to workout_trackpoint_path(@workout, @trackpoint)
    else
      render :action => "new"
    end
  end
  
  def update
    @workout = Workout.find(params[:workout_id])
    @trackpoint = Trackpoint.find(params[:id])
    if @trackpoint.update_attributes(params[:workout])
      redirect_to workout_trackpoint_path(@workout, @trackpoint)
    else
      render :action => "edit"
    end
  end
end
