class AddFieldsToWorkout < ActiveRecord::Migration
  def self.up
    add_column :workouts, :elevation_gain, :float
    add_column :workouts, :avg_speed, :float
  end

  def self.down
    remove_column :workouts, :avg_speed
    remove_column :workouts, :elevation_gain
  end
end
