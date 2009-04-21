#require 'WorkoutImporter'
require 'hpricot'
require 'Time'

class GarminImporter
  
  ## GARMIN times are all in UTC
  attr_reader :parsed_workout
  
  def initialize(xml_string, params = {}, time_zone = "UTC")
    @xml = Hpricot::XML(xml_string)
    @parsed_workout = params
    @time_zone = time_zone
  end

  def get_workout
    
    time = 0.0
    (@xml/:Lap).each do |lap|
      f_time =  (lap/:TotalTimeSeconds).innerHTML
      time += Float f_time
      
      # TODO- "DistanceMeters" is matching both in the Lap and trackpoint.
    end
    
    @parsed_workout['duration'] = time
    @parsed_workout['start_time'] = (@xml/:Id).innerHTML
    return @parsed_workout
  end
  
  def get_trackpoints
    trackpoints = Array.new
    
    (@xml/:Trackpoint).each do |t| 

      trackpoint = Hash.new
      next if ((t/:HeartRateBpm/:Value).innerHTML == "")
      trackpoint["heart_rate"] = (t/:HeartRateBpm/:Value).innerHTML
      trackpoint["lat"] = (t/:Position/:LatitudeDegrees).innerHTML
      trackpoint["lng"] = (t/:Position/:LongitudeDegrees).innerHTML
      trackpoint["time"] = (t/:Time).innerHTML
      trackpoint["altitude"] = (t/:AltitudeMeters).innerHTML
      trackpoint["distance"] = (t/:DistanceMeters).innerHTML


      trackpoints << trackpoint
    end 
    return trackpoints
  end
  
    # (doc/:Lap).each do |l|
    #       lap = Hash.new
    #       lap["duration"] = (l/:TotalTimeSeconds).innerHTML
    #       lap["distance"] = (l/:DistanceMeters).innerHTML
    #       lap["calories"] = (l/:Calories).innerHTML
    #       lap["average_hr"] = (l/:AverageHeartRateBpm/:Value).innerHTML
    #       lap["max_hr"] = (l/:MaximumHeartRateBpm/:Value).innerHTML
    
end

class PolarImporter
  
  ## Polar times are all local to user.
  def initialize(data, params = {}, time_zone = "UTC")
    @hrm_data = data
    @parsed_workout = params
    @time_zone = time_zone
  end

  def get_workout
  
    date = ''
    start = ''
    duration = 0
    
    hrm_array = @hrm_data.split("\n")
    hrm_array.each do |line|
      line.chomp!
      if (line =~ /Date=(.*$)/)
        date = $1
      end
      if (line =~ /StartTime=(\d+):(\d+):(\d+)\..*$/)
        start = $1 + $2 + $3
      end
      if (line =~/Length=(\d+):(\d+):(.*$)/)
        duration = Float($1) * 3600
        duration += Float($2) * 60
        duration += Float($3)
      end
    end
    
    start_time = date + start + @time_zone
    
    @parsed_workout['duration'] = duration
    @parsed_workout['start_time'] = start_time
    return @parsed_workout
    
  end
  
  def get_trackpoints
    
    start = ''
    interval = 0
    hr_data = 0
    date = ''
    time = ''
    trackpoints = Array.new
    
    hrm_array = @hrm_data.split("\n")
    hrm_array.each do |line|
      line.chomp!
      
      #Due to the hack below, if hr_data is 1, all subsequent is a HR point.  Assuming ALL data below is grabbed already.
      # TODO: ick
      if (hr_data == 1)
        trackpoint = Hash.new
        
        start_time = Time.parse("#{date} #{time} #{@time_zone}")
        tp_time = start_time + (interval.seconds * trackpoints.size)
        
        trackpoint["heart_rate"] = line
        trackpoint["time"] = tp_time
        trackpoints << trackpoint
      end
      
      if (line =~ /Date=(.*)$/)
        date = $1
      end
      if (line =~ /StartTime=(.*)$/)
        time = $1
      end
      if (line =~ /Interval=(.*$)/)
        interval = $1.to_i
      end
      if (line =~ /\[HRData\]/)
        hr_data = 1
      end
    end
    return trackpoints
  end
end