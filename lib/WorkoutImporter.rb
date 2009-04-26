#require 'WorkoutImporter'
require 'hpricot'
#require 'Time'

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

  # Polar times are all local to user.
  # params is a passed in array of parameters.  Use to merge in parsed data

  def initialize(data, params = {}, time_zone = "UTC")
    @polarHash = {}
    @polardata = data
    @parsed_workout = params
    @time_zone = time_zone
    restore
  end

  def restore
    parse_params
    parse_tabbed_blocks
    parse_single_data    
  end

  def get_workout
    date = @polarHash["params"]["Date"]
    length = @polarHash["params"]["Length"]
    start = @polarHash["params"]["StartTime"]

    length_array = length.split(/:/)
    duration = (length_array[0].to_f * 3600) + (length_array[1].to_f * 60) + (length_array[2].to_f)

    start_time = Time.parse("#{date} #{start} #{@time_zone}")

    @parsed_workout['duration'] = duration
    @parsed_workout['start_time'] = start_time
    return @parsed_workout
  end

  def get_trackpoints

    trackpoints = Array.new

    rrcounter = 0
    hr = 0
    tp_time = Time.now
    
    time = @polarHash["params"]["StartTime"]
    date = @polarHash["params"]["Date"]
    interval = @polarHash["params"]["Interval"].to_i

    @polarHash["HRData"].each do |hrd|
      trackpoint = Hash.new
      start_time = Time.parse("#{date} #{time} #{@time_zone}")

      # This is dependent on duration.
      if (interval == 238)
        rrcounter += hrd.to_i
        hr = hrd.to_i / 60000
        tp_time = start_time + (rrcounter/1000)
      else
        hr = hrd
        tp_time = start_time + (interval.seconds * trackpoints.size)
      end

      trackpoint["heart_rate"] = hr
      trackpoint["time"] = tp_time
      trackpoints << trackpoint
    end
    return trackpoints
  end



  def [](key)
    @polarHash[key]
  end

  def []=(key, value)
    raise TypeError, "String expected" unless key.is_a? String
    raise TypeError, "String or Hash expected" unless value.is_a? String or value.is_a? Hash

    @polarHash[key] = value
  end

  def parse_single_data
    single_blocks = %w[HRZones HRData]
    single_blocks.each do |block_name|
      @polarHash[block_name] = []
      block_text = find_block(block_name)
      block_text.each do |block_line|
        @polarHash[block_name] << block_line.chomp
      end
    end
  end

  def parse_tabbed_blocks
    # This is the list of tabbed blocks
    tabbed_blocks = %w[IntTimes ExtraData Sumary-123 Summary-TH]
    tabbed_blocks.each do |block_name|
      @polarHash[block_name] = []
      block_text = find_block(block_name)
      block_text.each do |block_line|
        @polarHash[block_name] << block_line.split(/\t/)
      end
    end
  end

  # Params is the only "ini" style block
  def parse_params
    @polarHash["params"] = {}
    param_block = find_block("Params")
    param_block.each do |param|
      key, value = param.split(/=/, 2)
      key = key.strip unless key.nil?
      value = value.strip unless value.nil?
      @polarHash["params"][key] = value unless key.nil?
    end
  end

  # Polar file has [Foo] blocks.  Return the data in the block
  def find_block(header)
    found = false
    block = []
    @polardata.each do |line|
      found = false if line =~ /\[.*\]/
      block << line  if found
      found = true if line =~ /\[#{header}\]/
    end
    return block
  end
end