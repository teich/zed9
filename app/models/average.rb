class Average < ActiveRecord::Base
  def self.calc_averages!

    # Average time working out per day for average user
    duration_per_day = calc_duration_per_day

    # Number of workouts for the average user
    workouts = calc_workouts

    # Average duration of average workout (single workout)
    duration = calc_duration

    # Average amount of time across workouts per user (all user's workouts)
    user_duration = calc_user_duration
    a = Average.create(:duration_per_day => duration_per_day, :workouts => workouts, 
                       :duration => duration, :user_duration => user_duration)
    if a.save
      return true
    else
      return false
    end
  end
    
    
  def self.calc_workouts
    User.find(:all).map {|u| u.workouts.processed.size}.aaverage
  end

  def self.calc_duration
    Workout.processed.map(&:duration).aaverage
  end
  
  def self.calc_user_duration
    User.find(:all).map {|u| u.workouts.processed.sum(:duration)}.aaverage
  end
  
  def self.calc_duration_per_day
    collector = []
    users = User.find(:all)
    users.each do |u|
      if u.workouts.processed.size > 0
        # puts "User #{u.login} has #{u.workouts.processed.size} workouts"
        days = (u.workouts.processed.last.start_time.to_date - u.workouts.processed.first.start_time.to_date).to_i
        days += 1 if days == 0
        time = u.workouts.sum(:duration)
        average = time / days
        collector << average
        # puts "----> and averaged #{average}"
        puts "#{average}, #{u.workouts.processed.count}"
      end
    end
    duration_per_day = collector.sum.to_f / collector.size
    # puts "TOTAL: average is #{duration_per_day}.  This came from #{collector.sum} sum in #{collector.size} items"
  end
end
