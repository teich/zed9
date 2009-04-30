class DashboardsController < ApplicationController
  def show
    @workouts = current_user.workouts.find(:all)
    
    # list of 5 most recent public workouts
    @shared = Workout.find_all_by_shared(true, :limit=>5, :order => "updated_at DESC")
    
    durations = @workouts.map { |w| w.duration }
    @total_time = durations.asum
    
    # TODO: pull out of controller!
    # figure out how much time users spend on average working out.  ick.
    users = User.find(:all)
    aud = users.map do |u|
      uw = u.workouts.find(:all)
      uwd = uw.map { |uwm| uwm.duration }
      utt = uwd.asum
    end 
    @atd = aud.aaverage
  end
end
