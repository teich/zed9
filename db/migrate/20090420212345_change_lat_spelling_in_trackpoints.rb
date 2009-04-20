class ChangeLatSpellingInTrackpoints < ActiveRecord::Migration
  def self.up
    rename_column :trackpoints, :latitude, :lat
    rename_column :trackpoints, :longitude, :lng
  end

  def self.down
    rename_column :trackpoints, :lng, :longitude
    rename_column :trackpoints, :lat
  end
end
