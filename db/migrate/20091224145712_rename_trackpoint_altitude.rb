class RenameTrackpointAltitude < ActiveRecord::Migration
  def self.up
    rename_column :trackpoints, :altitude, :elevation
  end

  def self.down
    rename_column :trackpoints, :elevation, :altitude
  end
end
