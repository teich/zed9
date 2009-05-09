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
  
  # Return the Global Information, AKA lat and lng.
  def gis
    gis = []
    for tp in trackpoints do
      if !tp.lat.nil?
        gis << [tp.lat, tp.lng]
      end
    end
    return gis
  end

  ## TODO: I think the hrmparser array function now includes this.  Nuke.
  def smooth_data(series, factor)
    series.in_groups_of(factor).map { |snipit| snipit.compact.aaverage }
  end
  
  def smooth_axis(series, factor)
    series.in_groups_of(factor).map { |snipit| snipit[0] }
  end
  # TODO: seconds conversion is in helper.  What's the DRY way of formatting this?
  def get_hr_axis
    trackpoints.map { |tp| tp.time - start_time }
  end
  
  def get_smoothed_hr(points, value_array = false, milliseconds = false)
    hr = get_hr
    factor = hr.size / points
    sd = smooth_data(hr, factor)
    point_interval = self.duration / sd.size
    if value_array
      c = -1
      vc = sd.map do |d|
        c += 1
        multiplier = milliseconds ? point_interval * 1000 : 1
        [(c*multiplier).to_i, d] # Converting to milliseconds for flot
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

  # def find_all_comps_by_activity(activity_id)
  #   Activity.find(activity_id).workouts
  # end
  # 
  # def find_my_comps_by_activity(activity_id)
  #   self.user.workouts.by_activity(activity_id)
  # end

  # TODO: Refactor comparison code somehow

  # TODO: The return nil check thing - seems lame
  def comps_average_hr(comps)
    if comps.size > 0
      hrs = comps.map { |comp| comp.hr }
      return hrs.compact.aaverage
    end
    return "N/A"
  end

  def comps_average_duration(comps)
    if comps.size > 0
      duration = pick_array_field(comps, :duration)
      return duration.compact.aaverage.round(1)
    end
    return "N/A"
  end

  # Take's an array of objects, and averages one field.
  def pick_array_field(data, field)
    data.map { |x| x[field] }
  end
  
  def gps_data?
    !trackpoints[0].nil? && !trackpoints[0].lat.nil?
  end

  def number_to_time(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end
  
  # Output: 2:03:45
  def number_to_short_time(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end

  def distance_in_miles
    return nil if self.distance.nil?
    (self.distance * 0.000621371192).round(1)
  end
  
  def avg_speed_in_mph
    return nil if self.speed.nil?
#    (self.distance_in_miles / self.duration * 3600).round(1)
    (self.speed * 2.23693629).round(1)
  end
  
  
  # def average_comps(comps, :field)
  #   points = comps.map {|c| c.:field}
  #   points.compact.average_array.round(1)
  # end
  def find_comps()
    mycomps = {}
    allcomps = {}
    
    mc = self.user.workouts.find_all_by_activity_id(activity.id)
    distance = (mc.map {|c| c.distance}).compact.aaverage
    speed = (mc.map {|c| c.speed}).compact.aaverage

    mycomps["hr"] = (mc.map { |c| c.hr  }).compact.aaverage
    mycomps["duration"] = (mc.map {|c| c.duration}).compact.aaverage
    mycomps["distance"]  = distance.round(1) if !distance.nil?
    mycomps["speed"] = speed.round(1) if !speed.nil?
    mycomps["elevation"] = (mc.map {|c| c.elevation}).compact.aaverage
    
    ac = Workout.find_all_by_activity_id(activity.id)
    distance = (ac.map {|c| c.distance}).compact.aaverage
    speed = (ac.map {|c| c.speed}).compact.aaverage
        
    allcomps["hr"] = (ac.map { |c| c.hr  }).compact.aaverage
    allcomps["duration"] = (ac.map {|c| c.duration}).compact.aaverage
    allcomps["distance"]  = distance.round(1) if !distance.nil?
    allcomps["speed"] = speed.round(1) if !speed.nil?
    allcomps["elevation"] = (ac.map {|c| c.elevation}).compact.aaverage
    
    
    return { :my_comps => mycomps, :all_comps => allcomps }
  end

  def json_comps
    find_comps
  end
  
  def json_date
    start_time.to_i
  end  

  def duration_formatted(url)
    length = (duration / 60).round 
    tooltip = "#{name}\n#{length} minutes"
    tooltip += "\n#{distance_in_miles} miles" if !distance.nil?
    { :value => length, :tooltip => tooltip, :url => url }

  end

  def elevation_formatted
    elevation_gain.nil? ? nil: elevation_gain.round
  end  
    
  def json_hr
    get_smoothed_hr(20, true)
  end
  
  def json_heartrate_big
    get_smoothed_hr(200, true, true)
  end
  
  def json_speed
    get_smoothed_speed(20,true)
  end
  
  def json_elevation
    get_smoothed_elevation(20,true)
  end
  
  def elevation_in_feet
    (elevation * 3.28).round(1)
  end
  
  def activity_name
    activity.name
  end
  
  def build_from_imported!(iw)
    self.hr = iw.average_hr
    self.speed = iw.average_speed
    self.distance = iw.distance
    self.duration = iw.duration
    self.start_time = iw.time
    self.elevation = iw.altitude_gain
    
    iw.trackpoints.each do |tp|
      wtp = trackpoints.build()
      wtp.altitude = tp.altitude
      wtp.distance = tp.distance
      wtp.lat = tp.lat
      wtp.lng = tp.lng
      wtp.speed = tp.speed
      wtp.time = tp.time
      wtp.heart_rate = tp.hr
    end
    
  end
    
end
