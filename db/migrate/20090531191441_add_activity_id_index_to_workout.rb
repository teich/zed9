class AddActivityIdIndexToWorkout < ActiveRecord::Migration
  def self.up
      add_index :workouts, :activity_id
  end

  def self.down
  end
end
