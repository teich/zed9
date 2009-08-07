class Gear < ActiveRecord::Base
	belongs_to :user
  # belongs_to :journal_entry
	validates_presence_of	:name
	
  has_many :workouts
	
  acts_as_taggable_on   :tags

  # This is removed so that form can update all fields. May need to correct for tagging workouts with gear.
  # attr_accessible :name, :tag
	
	def distance_used 
    workouts.sum(:distance)
	end
	
	def time_used
	  workouts.sum(:duration)
	end
	
	def percent_used_distance
    if distance_used && distance_max
	    ((distance_used / distance_max ) * 100 ).round
	  end
	end

	def percent_used_hours
	  if time_used && hours_max
	    ((time_used / hours_max ) * 100 ).round
	  end
	end
	
	def percent_remaining
    if distance_used && distance_max
      distance_remaining = 100 - ((distance_used / distance_max) * 100 ).round
      if distance_remaining <= 0
        distance_remaining = 0
      end
    end

    if time_used && hours_max
      hours_remaining = 100 - ((time_used / hours_max) * 100 ).round
      if hours_remaining <= 0
        hours_remaining = 0
      end
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
  
  def percent_remaining_style
    if percent_remaining <= 20
      return "red"
    end
  end
  
end
