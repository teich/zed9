class Gear < ActiveRecord::Base
	belongs_to :user
  # belongs_to :journal_entry
	validates_presence_of	:name
	
  has_many :workouts
	
  acts_as_taggable_on   :tags

	def distance_used 
    workouts.sum(:distance)
	end
	
	def time_used
	  workouts.sum(:duration)
	end
	
	def percent_used_distance
    if distance_used && distance_max && distance_max > 0
	    ((distance_used / distance_max ) * 100 ).round
	  end
	end

	def percent_used_hours
	  if time_used && hours_max && hours_max > 0
	    ((time_used / hours_max ) * 100 ).round
	  end
	end
	
	def percent_remaining

    if !distance_max.nil? && distance_max > 0
      distance_remaining = 100 - percent_used_distance 
    end  

    if !hours_max.nil? && hours_max > 0
      hours_remaining = 100 - percent_used_hours 
    end  

    if distance_remaining && hours_remaining
      if distance_remaining > hours_remaining
        return distance_remaining
      else 
        return hours_remaining
      end
    elsif distance_remaining
      return distance_remaining
    elsif hours_remaining
      return hours_remaining
    else
      return 0
    end
    
  end
  
  def percent_remaining_style
    if percent_remaining < 20
      return "red"
    end
  end
  
end
