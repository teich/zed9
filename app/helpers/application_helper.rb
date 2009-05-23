module ApplicationHelper
	def number_to_time(seconds)
		return nil if seconds.nil?
		Time.at(seconds).utc.strftime("%H:%M:%S")
	end

	# Output: 1:34 
	def number_to_short_time(seconds)
		return "0:00:00 " + seconds if seconds.nil?
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
	
	def units(workout, field)
		case field
		when :speed 
			workout.activity.pace ? "min/mile" : "mph"
		when :distance 
			workout.user.metric ? "km" : "miles"
		end
	end

  FLASH_NOTICE_KEYS = [:error, :warning, :notice, :info]
    def flash_messages
      return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
      formatted_messages = messages.map do |type|      
        content_tag :div, :class => type.to_s do
          message_for_item(flash[type], flash["#{type}_item".to_sym])
        end
      end
      formatted_messages.join
    end

    def message_for_item(message, item = nil)
      if item.is_a?(Array)
        message % link_to(*item)
      else
        message % item
      end
    end

end
