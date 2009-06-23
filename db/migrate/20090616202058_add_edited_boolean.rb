class AddEditedBoolean < ActiveRecord::Migration
  def self.up
    add_column :workouts, :edited, :boolean
  end

  def self.down
    remove_column :workouts, :edited
  end
end
