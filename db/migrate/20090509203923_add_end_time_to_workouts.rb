class AddEndTimeToWorkouts < ActiveRecord::Migration
  def self.up
    add_column :workouts, :end_time, :datetime
  end

  def self.down
    remove_column :workouts, :end_time
  end
end
