class AddImportingToWorkouts < ActiveRecord::Migration
  def self.up
    add_column :workouts, :importing, :boolean
  end

  def self.down
    remove_column :workouts, :importing
  end
end
