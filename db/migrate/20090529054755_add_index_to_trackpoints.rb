class AddIndexToTrackpoints < ActiveRecord::Migration
  def self.up
    add_index :trackpoints, :workout_id
  end

  def self.down
    remove_index :trackpoints, :workout_id
  end
end
