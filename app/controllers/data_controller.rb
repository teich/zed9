class DataController < ApplicationController
  def sparks
    workout = Workout.find(params[:workout_id])
    render :json => workout.comps(params[:q].intern)
  end
  
  def gis
    workout = Workout.find(params[:workout_id])
    render :json => workout.gis
  end
  
  def full
    workout = Workout.find(params[:workout_id])
    render :text => workout.full_data.to_json
  end
end
