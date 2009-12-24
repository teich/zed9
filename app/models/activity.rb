class Activity < ActiveRecord::Base
	acts_as_tree :order => "name"
  
	has_many :workouts
	
	attr_accessible :pace, :icon_path, :parent, :name, :parent_id

  def comp_average(field)
    w = self.workouts.map(&field).compact
    w.sum / w.size
  end
end
