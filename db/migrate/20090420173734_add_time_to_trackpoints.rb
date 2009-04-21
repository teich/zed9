class AddTimeToTrackpoints < ActiveRecord::Migration
  def self.up
    add_column :trackpoints, :time, :datetime
    add_column :trackpoints, :altitude, :float
    add_column :trackpoints, :distance, :float
  end

  def self.down
    remove_column :trackpoints, :distance
    remove_column :trackpoints, :altitude
    remove_column :trackpoints, :time
  end
end
