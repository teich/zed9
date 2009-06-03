class AddRpeToWorkouts < ActiveRecord::Migration
  def self.up
    add_column :workouts, :rpe, :integer
  end

  def self.down
    remove_column :workouts, :rpe
  end
end
