class AddRpeToWorkouts < ActiveRecord::Migration
  def self.up
    add_column :workouts, :rpe, :integer, :default => 0
  end

  def self.down
    remove_column :workouts, :rpe
  end
end
