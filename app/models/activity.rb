class Activity < ActiveRecord::Base
  acts_as_tree :order => "name"
  
  has_many :workouts
end
