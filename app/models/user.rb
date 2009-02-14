class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :workouts
  has_many :hr_zones
end
