class DataController < ApplicationController
  def index
  	
    # @workout = current_user.workouts.find(params[:workout_id])
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
end
