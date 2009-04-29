class CompsController < ApplicationController
  def show
    @workout = Workout.find(params[:workout_id])
    data = case params[:data]
      when "heartrate" 
        hr_s1 = { :data => @workout.get_smoothed_hr(25, true), :lines => { :show => true }}
        @comps = @workout.find_comps(@workout.user)
        hr_comp = {:data => [[26, @comps["global"]["hr"]], [27, @comps[@workout.activity.name]["hr"]], [28, @workout.average_hr]], :bars => { :show => true, :lineWidth => 1 }}
        #[hr_s1, hr_comp]
        {{:data => [[1,1],[1,2]]}, { :data => @workout.get_smoothed_hr(25, true), :lines => { :show => true }}}
        {{:bar => [1,1]}, {:foo => [2,2]}}
      when "speed"
        @workout.get_smoothed_speed(25, true)
      when "elevation"
        @workout.get_smoothed_elevation(25, true)
      else nil
    end 
    respond_to do |fmt|
      fmt.js { render :js => data.to_json }
    end
  end
end
