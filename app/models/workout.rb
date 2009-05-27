class Workout < ActiveRecord::Base
  # this just makes sure we have the trackpoint object so the deserialization works.
  Trackpoint
  
	belongs_to  :user
	belongs_to  :activity
 	has_many    :devices
	
	accepts_nested_attributes_for :devices

	validates_presence_of	:name
	validates_length_of 	:name,		:maximum => 100
	validates_length_of		:notes,		:maximum => 600
	
	serialize :trackpoints
	

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
		return 0 if trackpoints.size < 5
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
		#    (self.distance_in_miles / self.duration * 3600).round(1)
		(self.speed * 2.23693629).round(1)
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
		mycomps["speed"] = speed.round(1) if !speed.nil?
		mycomps["elevation"] = (mc.map {|c| c.elevation}).compact.aaverage

		ac = Workout.find_all_by_activity_id(activity.id)
		distance2 = (ac.map {|c| c.distance}).compact.aaverage
		speed2 = (ac.map {|c| c.speed}).compact.aaverage

		allcomps["hr"] = (ac.map { |c| c.hr  }).compact.aaverage
		allcomps["duration"] = (ac.map {|c| c.duration}).compact.aaverage
		allcomps["distance"]  = distance2.round(1) if !distance2.nil?
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

	def overlap?(user)
		overlapping = user.workouts.find(:all, :conditions => ['start_time <= ? AND end_time >= ?', self.end_time, self.start_time])
		overlapping.map { |o| o.id }
	end

	def build_from_imported!(iw)
	  self.trackpoints = []
		self.hr = iw.average_hr
		self.speed = iw.average_speed
		self.distance = iw.distance
		self.duration = iw.duration
		self.start_time = iw.time
		self.elevation = iw.altitude_gain

		iw.trackpoints.each do |tp|
			wtp = Trackpoint.new

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
end
