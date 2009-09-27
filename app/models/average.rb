class Average
  def self.calc_averages!
    calc_duration_per_day!
  end
    
  def self.calc_duration_per_day!
    collector = []
    users = User.find(:all)
    users.each do |u|
      puts "User #{u.login} has #{u.workouts.processed.size} workouts"
      if u.workouts.processed.size > 2
        days = (u.workouts.processed.last.start_time.to_date - u.workouts.processed.first.start_time.to_date).to_i
        time = u.workouts.sum(:duration)
        average = time / days
        collector << average
        puts "----> and averaged #{average}"
      end
    end
    duration_per_day = collector.sum.to_f / collector.size
    puts duration_per_day
  end
end
