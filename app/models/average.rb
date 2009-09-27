class Average < ActiveRecord::Base
  def self.calc_averages!
    duration_per_day = calc_duration_per_day
    workouts = calc_workouts
    duration = calc_duration
    a = Average.create(:duration_per_day => duration_per_day, :workouts => workouts, :duration => duration)
    a.save
  end
    
    
  def self.calc_workouts
    User.find(:all).map {|u| u.workouts.processed.size}.aaverage
  end

  def self.calc_duration
    Workout.processed.map(&:duration).aaverage
  end
  
  def self.calc_duration_per_day
    collector = []
    users = User.find(:all)
    users.each do |u|
      puts "User #{u.login} has #{u.workouts.processed.size} workouts"
      if u.workouts.processed.size > 0
        days = (u.workouts.processed.last.start_time.to_date - u.workouts.processed.first.start_time.to_date).to_i
        days += 1 if days == 0
        time = u.workouts.sum(:duration)
        average = time / days
        collector << average
        puts "----> and averaged #{average}"
      end
    end
    duration_per_day = collector.sum.to_f / collector.size
  end
end
