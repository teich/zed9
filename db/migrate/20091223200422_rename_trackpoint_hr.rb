class RenameTrackpointHr < ActiveRecord::Migration
  def self.up
    rename_column :trackpoints, :heart_rate, :hr
  end

  def self.down
    rename_column :trackpoints, :hr, :heart_rate
  end
end
