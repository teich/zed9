class TrackpointsController < ApplicationController
  def index
    @activity = Activity.find(params[:activity_id])
    @trackpoints = @activity.trackpoints
  end

  def show
    @activity = Activity.find(params[:activity_id])
    @trackpoint = Trackpoint.find(params[:id])
  end

  def new
    @activity = Activity.find(params[:activity_id])
    @trackpoint = @activity.trackpoints.build
  end

  def edit
    @activity = Activity.find(params[:activity_id])
    @trackpoint = Trackpoint.find(params[:id])
  end

  def create
    @activity = Activity.find(params[:activity_id])
    @trackpoint = @activity.trackpoints.build(params[:trackpoint])
    if @trackpoint.save
      redirect_to activity_trackpoint_path(@activity, @trackpoint)
    else
      render :action => "new"
    end
  end
  
  def update
    @activity = Activity.find(params[:activity_id])
    @trackpoint = Trackpoint.find(params[:id])
    if @trackpoint.update_attributes(params[:activity])
      redirect_to activity_trackpoint_path(@activity, @trackpoint)
    else
      render :action => "edit"
    end
  end
end
