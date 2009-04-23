class DashboardsController < ApplicationController
  def show
    @workouts = current_user.workouts.find(:all)
    durations = @workouts.map { |w| w.duration }
    @total_time = durations.array_sum
  end
end
