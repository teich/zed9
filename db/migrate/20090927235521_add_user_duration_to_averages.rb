class AddUserDurationToAverages < ActiveRecord::Migration
  def self.up
    add_column :averages, :user_duration, :float
  end

  def self.down
    remove_column :averages, :user_duration
  end
end
