class Gear < ActiveRecord::Base
	belongs_to :user
  # belongs_to :journal_entry
	validates_presence_of	:name
	
  has_many :workouts
	
  acts_as_taggable_on   :tags
	
  # attr_accessible :name, :tag
	
	def percent_used_distance
    if distance_used && distance_max
	    (distance_used / distance_max ).round
	  end
	end

	def percent_used_hours
	  if hours_used && hours_max
	    (hours_used / hours_max ).round
	  end
	end
	
	def percent_remaining
    if distance_used && distance_max
      distance_remaining = 100 - (distance_used / distance_max ).round
    end

    if hours_used && hours_max
      hours_remaining = 100 - (hours_used / hours_max ).round
    end

    if distance_remaining && hours_remaining
      if distance_remaining < hours_remaining 
        return distance_remaining 
      else hours_remaining < distance_remaining 
        return hours_remaining 
      end
    elsif distance_remaining
      return distance_remaining
    elsif hours_remaining
      return hours_remaining
    else return
    end
  end
  
end
