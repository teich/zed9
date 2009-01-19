class FixTrackpointSpelling < ActiveRecord::Migration
  def self.up
    rename_column "trackpoints", "longitutde", "longitude"
  end

  def self.down
    rename_column "trackpoints", "longitude", "longitutde"
  end
end
