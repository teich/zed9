class AddSharedStatusToWorkout < ActiveRecord::Migration
  def self.up
    add_column :workouts, :shared, :boolean
  end

  def self.down
    remove_column :workouts, :shared
  end
end
