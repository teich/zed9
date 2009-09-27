class Average
  def calc_averages!
    calc_duration_per_day!
  end
  
  private
  
  def calc_duration_per_day!
    collector = []
    users = User.find(:all)
    users.each do |u|
      if u.workouts.processed.size > 2
        days = (u.workouts.processed.last.start_time.to_date - u.workouts.processed.first.start_time.to_date).to_i
        time = u.workouts.sum(:duration)
        average = time / days
        collector << average
        puts "User #{u.login} did #{average}"
      end
    end
    duration_per_day = collector.sum.to_f / collector.size
    puts duration_per_day
  end
end
