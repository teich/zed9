class DashboardsController < ApplicationController
  def show
    @workouts = current_user.workouts.find(:all)
    durations = @workouts.map { |w| w.duration }
    @total_time = durations.array_sum
    
    users = User.find(:all)
    aud = users.map do |u|
      uw = u.workouts.find(:all)
      uwd = uw.map { |uwm| uwm.duration }
      utt = uwd.array_sum
    end 
    @atd = aud.average_array 
  end
end
