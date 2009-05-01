class RenameAveragesToSingularInWorkout < ActiveRecord::Migration
  def self.up
    rename_column :workouts, :average_hr, :hr
    rename_column :workouts, :avg_speed, :speed
    rename_column :workouts, :elevation_gain, :elevation
  end

  def self.down
    rename_column :workouts, :elevation, :elevation_gain
    rename_column :workouts, :speed, :avg_speed
    rename_column :workouts, :hr, :average_hr
  end
end
