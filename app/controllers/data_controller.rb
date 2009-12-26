class DataController < ApplicationController
  def sparks
    workout = Workout.find(params[:workout_id])

    case params[:q]
    when "distance"
      data = workout.comps(:distance)
    when "duration"
      data = workout.comps(:duration)
    when "speed"
      data = workout.comps(:speed)
    when "elevation"
      data = workout.comps(:elevation)
    when "hr"
      data = workout.comps(:hr)
    when "calories"
      data = workout.comps(:calories)
    end
    render :js => data.to_json
  end
  
  def gis
    workout = Workout.find(params[:workout_id])
    render :js => workout.gis.to_json
  end
end
