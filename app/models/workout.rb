class Workout < ActiveRecord::Base
  belongs_to  :users
  has_many    :trackpoints
  
  validates_presence_of :name
  validates_length_of   :name,     :maximum => 100
  
  acts_as_taggable_on   :tags
end
