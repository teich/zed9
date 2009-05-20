class Achievement < ActiveRecord::Base
	has_many :accomplishments
	has_many :users, :through => :accomplishments
	has_one :precondition, :class_name => "Achievement", :foreign_key => "precondition_id"
end
