class DataController < ApplicationController
	before_filter :find_workout
	
  def sparks
    render :json => @workout.comps(params[:q].intern)
  end
  
  def gis
    render :json => @workout.gis
  end
  
  def full
    render :json => @workout.full_data
  end
  
  def find_workout
		@workout = Workout.find(params[:workout_id])
	end
end
