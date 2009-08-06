class Gear < ActiveRecord::Base
	belongs_to :user
  # belongs_to :journal_entry
	validates_presence_of	:name
	validates_presence_of :purchase_date
	
	has_many :workouts
	
	attr_accessible :name, :tag
	
	def percent_used_distance
	  (distance_used / distance_max ).round
	end

	def percent_used_hours
	  (hours_used / hours_max ).round
	end
	
end
