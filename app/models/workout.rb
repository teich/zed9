class Workout < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :activity
  has_many    :trackpoints, :dependent => :destroy
  has_many    :comps

  validates_presence_of :name
  validates_length_of   :name,     :maximum => 100

  validates_presence_of :user_id

  acts_as_taggable_on   :tags

  def get_hr
    trackpoints.map {|a|a.heart_rate}
  end
  
  def get_speed
    trackpoints.map { |tp| tp.speed }
  end
  
  def get_elevation
    trackpoints.map { |tp| tp.altitude }
  end

  def calc_avg_hr
    get_hr.compact.average_array
  end
  
  def calc_average_speed
    get_speed.compact.average_array
  end
  
  def calc_elevation_gain
    gain = 0
    averaged_altitude = smooth_data(get_elevation, 10)
    start = averaged_altitude.first
    averaged_altitude.each do |alt|
      diff = alt - start
      if (diff > 0)
        gain += diff
      end
      start = alt
    end
    return gain
  end

  def smooth_data(series, factor)
    series.in_groups_of(factor).map { |snipit| snipit.compact.average_array }
  end
  
  def smooth_axis(series, factor)
    series.in_groups_of(factor).map { |snipit| snipit[0] }
  end
  # TODO: seconds conversion is in helper.  What's the DRY way of formatting this?
  def get_hr_axis
    trackpoints.map { |tp| tp.time - start_time }
  end
  
  def get_smoothed_hr(points, value_array = false)
    hr = get_hr
    factor = hr.size / points
    sd = smooth_data(hr, factor)
    if value_array
      c = -1
      vc = sd.map do |d|
        c += 1
        [c, d]
      end
      return vc
    else
      return sd
    end
  end
  
  def get_smoothed_speed(points, value_array = false)
    speed = get_speed
    factor = speed.size / points
    smoothed = smooth_data(speed, factor)
    if value_array
      c = -1
      vc = smoothed.map do |d|
        c += 1
        [c, d]
      end
      return vc
    else
      return smoothed
    end
  end
  
  def get_smoothed_elevation(points, value_array = false)
    elevation = get_elevation
    factor = elevation.size / points
    smoothed = smooth_data(elevation, factor)
    if value_array
      c = -1
      vc = smoothed.map do |d|
        c += 1
        [c, d]
      end
      return vc
    else
      return smoothed
    end
  end
  
  def get_smoothed_hr_axis(points)
    hra = get_hr_axis
    factor = hra.size / points
    smooth_axis(hra, factor)
  end
  
  def get_smoothed_and_formated_hr_axis(points)
    seconds = get_smoothed_hr_axis(points)
    seconds.map { |s| number_to_time(s) }
  end
  def find_all_comps_by_activity(activity_id)
    @all_comps ||= Activity.find(activity_id).workouts
  end
  
  def find_user_comps_by_activity(user_id, activity_id)
    user = User.find(user_id)
    @my_comps ||= user.workouts.by_activity(activity_id)
  end

  # TODO: Refactor comparison code somehow
#  def find_comps(user)
#    all_comps = find_all_comps_by_activity(activity.id)
#    my_comps = find_user_comps_by_activity(user, activity.id)
#    return [my_comps, all_comps]
#  end

  # TODO: The return nil check thing - seems lame
  def comps_average_hr(comps)
    if comps.size > 0
      hrs = comps.map { |comp| comp.average_hr }
      return hrs.compact.average_array
    end
    return "N/A"
  end

  def comps_average_duration(comps)
    if comps.size > 0
      duration = pick_array_field(comps, :duration)
      return duration.compact.average_array.round(1)
    end
    return "N/A"
  end

  # Take's an array of objects, and averages one field.
  def pick_array_field(data, field)
    data.map { |x| x[field] }
  end
  
  def gps_data?
    !trackpoints[0].lat.nil?
  end

  def number_to_time(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end
  
  def number_to_short_time(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end

  def distance_in_miles
    return nil if self.distance.nil?
    (self.distance * 0.000621371192).round(1)
  end
  
  def avg_speed_in_mph
    return nil if self.distance_in_miles.nil?
    (self.distance_in_miles / self.duration * 3600).round(1)
  end
  
  
  # def average_comps(comps, :field)
  #   points = comps.map {|c| c.:field}
  #   points.compact.average_array.round(1)
  # end
  def find_comps(user)
    comps = {}

    my_comps = user.workouts.find_all_by_activity_id(activity.id)
    comps[activity.name] = {}
    
    comps[activity.name]["hr"] = (my_comps.map { |c| c.average_hr  }).compact.average_array
    comps[activity.name]["duration"] = (my_comps.map {|c| c.duration}).compact.average_array
    comps[activity.name]["distance"] = (my_comps.map {|c| c.distance_in_miles}).compact.average_array.round(1)
    comps[activity.name]["speed"] = (my_comps.map {|c| c.avg_speed_in_mph}).compact.average_array.round(1)
    
    all_comps = Workout.find_all_by_activity_id(activity.id)
    comps["global"] = {}
    comps["global"]["hr"] = (all_comps.map { |c| c.average_hr  }).compact.average_array
    comps["global"]["duration"] = (all_comps.map {|c| c.duration}).compact.average_array
    comps["global"]["distance"] = (all_comps.map {|c| c.distance_in_miles}).compact.average_array.round(1)
    comps["global"]["speed"] = (all_comps.map {|c| c.avg_speed_in_mph}).compact.average_array.round(1)
    
    return comps
  end

  def duration_formatted(url)
    length = (duration / 60).round 
    tooltip = "#{name}\n#{length} minutes"
    tooltip += "\n#{distance_in_miles} miles" if !distance.nil?
    { :value => length, :tooltip => tooltip, :url => url }

  end

  def elevation_formatted()
    (elevation_gain).round
  end  
    
  def json_heartrate
    get_smoothed_hr(20, true)
  end
  
  def json_heartrate_big
    get_smoothed_hr(200, true)
  end
  
  def json_speed
    get_smoothed_speed(20,true)
  end
  
  def json_elevation
    get_smoothed_elevation(20,true)
  end
    
end
