module ApplicationHelper
  
	def number_to_time(seconds)
		return nil if seconds.nil?
		Time.at(seconds).utc.strftime("%H:%M:%S")
	end

	# Output: 1:34 
	def number_to_short_time(seconds)
		return "0:00:00 " if seconds.nil?
		hours = (seconds / 3600).to_i
		minutes = ((seconds - 3600 * hours) / 60).to_i
		minutes = "0#{minutes}" if minutes < 10 # hack to add leading 0

		return "#{hours}:#{minutes}"
	end

	# Output: Monday, April 06, 2009 at 11:58am
	def activity_timestamp(start_time)
		return "" if start_time.nil?
		time = start_time.strftime("%I:%M%p")
		if (time =~ /^0(.*$)/)
			short_time = $1
		else
			short_time = time
		end
		start_time.strftime("%A, %B %d, %Y at #{short_time.downcase}")
	end

	# Output: Monday 4/06/09 at 11:58am
	def activity_timestamp_shorter(start_time)
  		return "" if start_time.nil?
  		time = start_time.strftime("%I:%M%p")
  		if (time =~ /^0(.*$)/)
  			short_time = $1
  		else
  			short_time = time
  		end
  		month = start_time.strftime("%m")
  		if (month =~ /^0(.*$)/)
  			short_month = $1
  		else
  			short_month = month
  		end
  		day = start_time.strftime("%d")
  		if (day =~ /^0(.*$)/)
  			short_day = $1
  		else
  			short_day = day
  		end
  		start_time.strftime("%A, #{short_month}/#{short_day}/%g at #{short_time.downcase}")
  	end

	# Output: 5/8/09
	def time_as_date(start_time)
		return "" if start_time.nil?
		month = start_time.strftime("%m")
		if (month =~ /^0(.*$)/)
			short_month = $1
		else
			short_month = month
		end
		day = start_time.strftime("%d")
		if (day =~ /^0(.*$)/)
			short_day = $1
		else
			short_day = day
		end
		start_time.strftime("#{short_month}/#{short_day}/%g")
	end

	def float_min_to_formated_time(time)
		min = time.to_i
		sec = (time % 1 * 60).to_i
		sec = "0#{sec}" if sec < 10
		return "#{min}:#{sec}"
	end
	
	def speed_to_pace(workout)
		metric = workout.user.metric
		pace = workout.activity.pace
		speed = workout.speed
		
		# workout speed is set to meters per second.
		if metric
			speed *= 3.6
		else
			speed *= 2.23693629
		end
		
		if pace
			return float_min_to_formated_time(60 / speed) 
		else
			return speed.round(1)
		end
		
	end
	
	def max_speed_to_pace(workout)

		metric = workout.user.metric
		pace = workout.activity.pace
		max_speed = workout.trackpoints.maximum(:speed)
		
		# workout speed is set to meters per second.
		if metric
			max_speed *= 3.6
		else
			max_speed *= 2.23693629
		end
		
		if pace
			return float_min_to_formated_time(60 / max_speed) 
		else
			return max_speed.round(1)
		end
		
	end

	def units(workout, field)
		case field
		when :speed 
			workout.activity.pace ? "min/mile" : "mph"
		when :distance 
			workout.user.metric ? "km" : "miles"
		end
	end
  
	def units_short(workout, field)
		case field
		when :speed 
			workout.activity.pace ? "min/mi" : "mph"
		when :distance 
			workout.user.metric ? "km" : "mi"
		end
	end

  def no_leaders?
    @farthest.size == 0 && @fastest.size == 0 && @longest.size == 0 && @climbers.size == 0 && @heart_pumping.size == 0
  end
  
end
