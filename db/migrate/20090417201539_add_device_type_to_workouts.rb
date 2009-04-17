class AddDeviceTypeToWorkouts < ActiveRecord::Migration
  def self.up
    add_column :workouts, :device_type, :string
  end

  def self.down
    remove_column :workouts, :device_type
  end
end
