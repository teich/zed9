module ApplicationHelper
  
  
  def seconds_to_hours(seconds)
    return (seconds/3600)
  end
  
  def currency_formatted(price)
    m = price.to_s.split(".")
    if (m[1].size == 2)
      return price
    else
      d = m[0]
      if (m[1].nil? || m[1].size == 0)
        c = 00
      elsif (m[1].size == 1)
        c = m[1] + "0"
      end
    return "#{d}.#{c}"
    end
  end

  def meters_to_miles(distance)
		return nil if distance.nil?
		(distance * 0.000621371192).round(1)
	end

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
	
	# Output: 34
	def number_to_mins(seconds)
		minutes = (seconds / 60).to_i
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
      start_time.strftime("%A %b %d %Y at %I:%M%p")
      # time = start_time.strftime("%I:%M%p")
      # if (time =~ /^0(.*$)/)
      #   short_time = $1
      # else
      #   short_time = time
      # end
      # month = start_time.strftime("%m")
      # if (month =~ /^0(.*$)/)
      #   short_month = $1
      # else
      #   short_month = month
      # end
      # day = start_time.strftime("%d")
      # if (day =~ /^0(.*$)/)
      #   short_day = $1
      # else
      #   short_day = day
      # end
      # start_time.strftime("%A, #{short_month}/#{short_day}/%g at #{short_time.downcase}")
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

  #Output 5/8/09 for date-select inputs (e.g., on Journal Entries)
  def format_date_select(entry_date)
		return "" if entry_date.nil?
    orig_date = entry_date.to_s.split("-")
    year = orig_date[0]
    short_year = year[-2..3]
    month = orig_date[1]
    day = orig_date[2]
    if (month =~ /^0(.*$)/)
      short_month = $1
    else
      short_month = month
    end
    if (day =~ /^0(.*$)/)
      short_day = $1
    else
      short_day = day
    end
    return short_month + "/" + short_day + "/" + short_year
  end

	def float_min_to_formated_time(time)
		min = time.to_i
		sec = (time % 1 * 60).to_i
		sec = "0#{sec}" if sec < 10
		return "#{min}:#{sec}"
	end
	
	def speed_to_pace(workout)
    # TODO: this is ugly, muts be a more ruby way
		speed = workout.localize_data(workout.speed, :speed)
		
		if workout.activity.pace
			return float_min_to_formated_time(60 / speed) 
		else
			return speed.round(1)
		end
		
	end
	
	def max_speed_to_pace(workout)

		max_speed = workout.localize_data(workout.max_speed, :speed)
		
		if workout.activity.pace
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

  def two_digits(value)
    return "" if value.nil?
    return value if value >  9 
		return "0#{value}"
  end
  
  def no_leaders?
    @farthest.size == 0 && @fastest.size == 0 && @longest.size == 0 && @climbers.size == 0 && @heart_pumping.size == 0
  end

  def find_commentable(type, id)
    return type.classify.constantize.find(id)
  end
  
  def truncate_words(text, length = 30, end_string = ' …')
    return if text == nil
    words = text.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end  
end
