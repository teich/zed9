class Accomplishment < ActiveRecord::Base
	belongs_to :workout
	belongs_to :achievement
end	
