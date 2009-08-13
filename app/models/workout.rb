class Workout < ActiveRecord::Base
  
	belongs_to  :user
	belongs_to  :activity
	belongs_to  :gear
	has_many    :trackpoints, :order => 'time ASC'
	has_many    :devices
	
	accepts_nested_attributes_for :devices

	validates_presence_of	:name
	validates_length_of 	:name,		:maximum => 100
	validates_length_of		:notes,		:maximum => 600
	validates_presence_of :user_id
	
	validates_presence_of :duration, :if => :manual_entry?
  validates_presence_of :start_time, :if => :manual_entry?
  
	acts_as_taggable_on   :tags
	
	named_scope :processed, :conditions => { :importing => false }
	
	def start_time_string
	  start_time.to_s
	end

  def start_time_string=(start_time_str)
    self.start_time = Time.parse(start_time_str)
  end
  
  def end_time_string
	  end_time.to_s
	end

  def end_time_string=(end_time_str)
    self.end_time = Time.parse(end_time_str)
  end
	
	
	def unzip!
	  tmp_dir = (0...8).map{65.+(rand(25)).chr}.join
    dest = RAILS_ROOT + "/tmp/" + tmp_dir
    workout_file_name = devices.first.source_file_name
    
    Dir::mkdir(dest)
    logger.debug "Made directory #{dest}"

    if ENV['S3_BUCKET']
      f = File.open("#{dest}/#{workout_file_name}", "w+")
      f.puts workout.to_file.data
      f.close
    else
      status = File.copy(devices.first.source.path, dest)
      logger.debug "Coppied file #{devices.first.soure.path} to #{dest} with status #{status}"
    end

    status = `unzip #{dest}/#{workout_file_name} -d #{dest}`
    logger.debug "Unzipped file #{workout_file_name} with status #{status}"
    
    File.delete("#{dest}/#{workout_file_name}")
    logger.debug "Deleted the original zip file"
    
    Dir["#{dest}/*.*"].each do |file|
      logger.debug "Found this: #{file}"
      zip_workout = self.clone
      zip_workout.devices.first.source = File.open file
      zip_workout.name = "UNNAMED - $zip_workout.devices.first.source_file_name"
      zip_work.save
      File.delete file
    end
    
    FileUtils.rm_rf dest
    
  end
  
  def perform
    
    # Make sure there is no existing data
    trackpoints.map { |tp| tp.destroy }
    
    # Import the data
  
    if (devices.first.zip?)
      self.unzip!
      self.destroy
    else
      type = Importer.file_type(devices.first.source_file_name)

      uploaded_data = ensure_string(devices.first.source.to_file)

      case type
      when "GARMIN_XML"
        importer = Importer::Garmin.new(:data => uploaded_data)
      when "POLAR_HRM"
        importer = Importer::Polar.new(:data => uploaded_data, :time_zone => self.user.time_zone)
      when "SUUNTO"
        importer = Importer::Suunto.new(:data => uploaded_data, :time_zone => self.user.time_zone)
      when "GPX"
        importer = Importer::GPX.new(:data => uploaded_data)
      end

      iw = importer.restore
      self.build_from_imported!(iw)
      self.importing = false
      if self.save
        self.check_achievements
        return true
      else
        puts "Something went wrong"
        return false
      end
    end    
  end
  
  def reprocess!
    self.importing = true
    self.save
    Delayed::Job.enqueue WorkoutJob.new(self.id)
  end

  def check_achievements
    achievements = Achievement.find(:all, :conditions => ['controller = ? AND action = ?', "workouts", "create"])
    @workout = self
    current_user = self.user
    achievements.each do |a|
      if eval a.logic and !self.user.awarded?(a)
        self.user.award(a)
        #add_flash(:achievement, "You've earned a new achievement: #{a.name}")
      end
    end
  end
  
	def ensure_string(uploaded_file)
		if uploaded_file.is_a?(String) 
		  return uploaded_file
	  elsif uploaded_file.is_a?(File)
		  return uploaded_file.read
	  elsif uploaded_file.is_a?(RightAws::S3::Key)
	    return uploaded_file.data
	  end
	end
	
	def trackpoints?
	  trackpoints.size > 0
	end
	
	def get_hr
		trackpoints.map {|a|a.heart_rate}
	end

	def get_speed
    trackpoints.map { |tp| tp.speed }
	end

	def get_elevation
		trackpoints.map { |tp| tp.altitude }
	end

  def max_speed
    found = 0
    speeds = trackpoints.map { |tp| tp.speed }.compact
    speeds.compact.each_index do |x|
      if x < (speeds.length - 20)
        avg = speeds[x..x+4].aaverage
        found = avg if avg > found
      end
    end
    return found
  end
  
	# Return the Global Information, AKA lat and lng.
	def gis
		gis = []
		return gis if trackpoints.size < 5
		start = trackpoints.first.time
		for tp in trackpoints do
			if !tp.lat.nil?
				gis << {:time => ((tp.time - start) / 10).round, :data => [tp.lat, tp.lng]}
			end
		end
		return gis
	end

	def smooth_data(series, factor)
		return series if factor == 0
		series.in_groups_of(factor).map { |snipit| snipit.compact.aaverage }
	end

	def smooth_axis(series, factor)
		series.in_groups_of(factor).map { |snipit| snipit[0] }
	end

	# TODO: seconds conversion is in helper.  What's the DRY way of formatting this?
	# def get_hr_axis
	# 	trackpoints.map { |tp| tp.time - start_time }
	# end

	def get_smoothed_hr(points, value_array = false, milliseconds = false)
		hr = get_hr.compact
		return nil if hr.size == 0

		vc = []
		factor = hr.size / points
		sd = smooth_data(hr, factor)
		point_interval = self.duration / sd.size
		if value_array
			c = -1
			vc = sd.map do |d|
				c += 1
				if milliseconds
					axis = c * point_interval * 1000
				else
					axis = c
				end
				[axis.to_i, d] 
			end
			return vc
		else
			return sd
		end
	end

	def get_smoothed_speed(points, value_array = false, milliseconds = false)
		speed = get_speed.compact
		return nil if speed.size == 0
		factor = speed.size / points
		smoothed = smooth_data(speed, factor)
		point_interval = self.duration / smoothed.size

		if value_array
			c = -1
			vc = smoothed.map do |d|
				c += 1
				multiplier = milliseconds ? point_interval * 1000 : 1
				
				# TODOL Converting to speed inline right now.  Ick.
				# Converting to milliseconds for flot
				[(c*multiplier).to_i, d] 
			end
			return vc
		else
			return smoothed
		end
	end

	def get_smoothed_elevation(points, value_array = false, milliseconds = false)
		elevation = get_elevation.compact
		return nil if elevation.size == 0

		factor = elevation.size / points
		smoothed = smooth_data(elevation, factor)
		point_interval = self.duration / smoothed.size

		if value_array
			c = -1
			vc = smoothed.map do |d|
				c += 1
				multiplier = milliseconds ? point_interval * 1000 : 1
				[(c*multiplier).to_i, d] # Converting to milliseconds for flot
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


  def calories()
    gender = user.sex
    age = ( (Date.today - user.birthdate).to_i / 365.25).floor
    
    # FORMULA WITHOUT V02 MAX 
    # if gender && age && user.weight(self.start_time) && duration && hr
    #   if gender == "male"  
    #     cal = (-55.0969 + (hr * 0.6309) + (user.weight(self.start_time) * 0.1988) + (age * 0.2017) ) / 4.184
    #     totalcal = (cal * duration/60).to_i
    #     return totalcal
    #   elsif gender == "female"
    #     cal = ( -20.4022 + (hr * 0.4472) + (user.weight(self.start_time) * 0.1263) + (age * 0.074) ) / 4.184
    #     totalcal = (cal * duration/60).to_i
    #     return totalcal
    #   end

    # FORMULA WITH V02 MAX
    if gender && age && user.weight(self.start_time) && duration && hr
      if gender == "male"  
        cal = ( -59.3954 - 36.3781 + (hr * 0.634) + (user.weight(self.start_time) * 0.394) + (age * 0.271) + (user.vo2(start_time) * 0.404) ) / 4.184
        totalcal = (cal * duration/60).to_i
        return totalcal
      elsif gender == "female"
        cal = ( -59.3954 + (hr * 0.450) + (user.weight(self.start_time) * 0.103) + (age * 0.274) + (user.vo2(start_time) * 0.380) ) / 4.184
        totalcal = (cal * duration/60).to_i
        return totalcal
      end
    else
      return nil
    end

  end
    

	# Take's an array of objects, and averages one field.
	def pick_array_field(data, field)
		data.map { |x| x[field] }
	end

	def gps_data?
		return gis.size > 0
	end

	def number_to_time(seconds)
		Time.at(seconds).utc.strftime("%H:%M:%S")
	end

	def number_to_short_time(seconds)
		return "0:00:00 " if seconds.nil?
	Time.at(seconds).utc.strftime("%H:%M:%S")
	end

	def distance_in_miles
		return nil if self.distance.nil?
		(self.distance * 0.000621371192).round(1)
	end

	def avg_speed_in_mph
		return nil if self.speed.nil?
       (self.distance_in_miles / (self.duration * 3600)).round(1)
    # (self.speed * 2.23693629).round(1)
	end


	def find_comps()
		mycomps = {}
		allcomps = {}

		mc = self.user.workouts.find_all_by_activity_id(activity.id)
		distance = (mc.map {|c| c.distance}).compact.aaverage
		speed = (mc.map {|c| c.speed}).compact.aaverage

		mycomps["hr"] = (mc.map { |c| c.hr  }).compact.aaverage
		mycomps["duration"] = (mc.map {|c| c.duration}).compact.aaverage
		mycomps["distance"]  = distance.round(1) if !distance.nil?
    mycomps["calories"] = (mc.map {|c| c.calories}).compact.aaverage.round if !calories.nil?
		mycomps["speed"] = speed.round(1) if !speed.nil?
		mycomps["elevation"] = (mc.map {|c| c.elevation}).compact.aaverage

		ac = Workout.find_all_by_activity_id(activity.id)
		distance2 = (ac.map {|c| c.distance}).compact.aaverage
		speed2 = (ac.map {|c| c.speed}).compact.aaverage

		allcomps["hr"] = (ac.map { |c| c.hr  }).compact.aaverage
		allcomps["duration"] = (ac.map {|c| c.duration}).compact.aaverage
		allcomps["distance"]  = distance2.round(1) if !distance2.nil?
    allcomps["calories"] = (ac.map {|c| c.calories}).compact.aaverage.round if !calories.nil?
		allcomps["speed"] = speed2.round(1) if !speed2.nil?
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

		#get trackpoints that have a HR
		hr_trackpoints = trackpoints.map { |tp| tp if (!tp.heart_rate.nil? && tp.heart_rate > 0) }
		hr_trackpoints.compact!
		return nil if hr_trackpoints.first.nil?

		#Find first offset
		start_offset = hr_trackpoints.first.time - start_time

		#Find last offset
		end_offset = end_time - hr_trackpoints.last.time
		start_percent = start_offset / duration
		end_percent = end_offset / duration

		# we can't have more points than we have data.  Scale down if needed
		number_points = 200 > hr_trackpoints.size ? hr_trackpoints.size : 200

		first_blanks = (number_points * start_percent).to_i
		end_blanks = (number_points * end_percent).to_i
		points = []

		# flot wants things in milliseconds. 
		step = (duration * 1000 / number_points).to_i
		first_blanks.times { |i| points << [step * i, nil] }

		graphing_points = number_points - first_blanks - end_blanks
		factor = hr_trackpoints.size / graphing_points
		#factor = 1 if factor == 0
		graphing_points.times do |i| 
			points << [step * (i+first_blanks), hr_trackpoints[i * factor].heart_rate]
		end
		points
	end

	def json_speed
		get_smoothed_speed(20,true)
	end

	def json_speed_big
		get_smoothed_speed(200, true, true)
	end

	def json_elevation_big
		get_smoothed_elevation(200,true, true)
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

	def overlaps?
		overlapping = self.user.workouts.find(:all, :conditions => ['start_time <= ? AND end_time >= ?', self.end_time, self.start_time])
		overlapping.size > 1
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
			self.trackpoints << wtp
		end

		self.end_time = self.trackpoints.last.time
		self.devices_processed_at = Time.now

	end

	def calc_average_hr
		get_hr.compact.aaverage
	end
	
	def week
	  start_time.strftime('%Y%W')
  end
  
  def month
    start_time.strftime('%Y%m')
  end
  
  def max(field)
    trackpoints.maximum(field)
  end

	def calc_average_speed
		get_speed.compact.aaverage
	end

	def calc_altitude_gain
		gain = 0
		smoothed_altitude = get_elevation.compact.smoothed(10)
		start = smoothed_altitude.first
		smoothed_altitude.each do |alt|
			diff = alt - start
			if (diff > 0)
				gain += diff
			end
			start = alt
		end
		@altitude_gain = gain

	end
	
	def graph_fields
	  fields = []
	  if !self.hr.nil? && self.hr > 0
	    fields << ["heartrate", "Heart Rate"]
    end
    
    if !self.speed.nil? && self.speed > 0
      fields << ["speed", "Speed"]
    end
    
    if !self.elevation.nil? && self.elevation > 0
      fields << ["elevation", "Elevation"]
    end
    return fields
  end
  
  def manual_entry?
    devices.first.mfg == "MANUAL"
  end
  
  def clear_gear_tags
    gear_labels = user.gears.map { |t| t.tag }
    for gear_label in gear_labels
      tag_list.remove(gear_label)
    end
    self.save
  end
  
  def set_defaults!
    # Defaults to last selected activity type
     last_workout = user.workouts.first
     if last_workout.nil?
       self.activity = Activity.find_by_name("Uncategorized")
     else
       self.activity = last_workout.activity
       self.gear = last_workout.gear
     end

 		# Set the workout shared state to the user default
 		self.shared = user.shared  
  end
  

  def workouts_nearby
    if gps_data?
      distance = 0.005

      location = trackpoints.find(:first, :conditions => ['lat IS NOT NULL AND lng IS NOT NULL'])
      # logger.debug(location)
      min_lat = location.lat - distance
      max_lat = location.lat + distance
      min_lng = location.lng - distance
      max_lng = location.lng + distance

      nearby = Trackpoint.find(:all, :conditions => ["lat > ? AND lat < ? AND lng > ? AND lng < ?", min_lat, max_lat, min_lng, max_lng], :select => "DISTINCT workout_id").map {|tp| tp.workout_id }
      
      workouts_nearby = Workout.find(:all, :conditions => ["id in (?)", nearby], :limit => 10)
      return workouts_nearby
    else return nil
    end
  end

end
