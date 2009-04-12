class ChangeWorkoutDurationToFloat < ActiveRecord::Migration
  def self.up
    change_column :workouts, :duration, :float
  end

  def self.down
    change_column :workouts, :duration, :integer
  end
end
