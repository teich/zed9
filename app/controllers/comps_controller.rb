class CompsController < ApplicationController
  def show
    @workout = Workout.find(params[:workout_id])
    data = case params[:data]
      when "HR" 
        @workout.get_smoothed_hr(23, true)
      when "SPEED"
        @workout.get_smoothed_hr(50, true)
      when "ELEVATION"
        @workout.get_smoothed_hr(100, true)
      else nil
    end 
    respond_to do |fmt|
      fmt.js { render :js => data.to_json }
    end
  end
end
