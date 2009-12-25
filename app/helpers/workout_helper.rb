module WorkoutHelper
  def workouts_per_week(user)
    strings = []
    user.workouts.group_by(&:week).each do |week,workouts| 
      duration = workouts.inject(0) { |r, e| r + e.duration}
      count = workouts.size
      strings << "#{week} - #{count} #{duration}"
    end
    return strings
  end
  
  def meters_to_feet(meters)
    return (meters * 3.2808399).round
  end
  
  def mps_to_mph(mps)
    return (mps *2.23693629).round(1)
  end

  def sparktype(workout)
    if workout.trackpoints? 
      "line"
    else
      "bar"
    end
  end

  def elevation_max(workout)
    elevation_max || workout.max(:elevation) 
  end
  
  def hr_max(workout)
    hr_max || workout.max(:heart_rate)
  end

end