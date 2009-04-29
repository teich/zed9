class AddSpeedToTrackpoints < ActiveRecord::Migration
  def self.up
    add_column :trackpoints, :speed, :float
  end

  def self.down
    remove_column :trackpoints, :speed
  end
end
