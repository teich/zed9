class AddActivityToWorkout < ActiveRecord::Migration
  def self.up
    add_column :workouts, :activity_id, :integer, :default => 0 
  end

  def self.down
    remove_column :workouts, :activity_id
  end
end
