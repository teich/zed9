class AddDeviceProcessedToWorkout < ActiveRecord::Migration
  def self.up
		add_column :workouts, :devices_processed_at, :datetime
  end

  def self.down
		remove_column :workouts, :devices_processed_at
  end
end
