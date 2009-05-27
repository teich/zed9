class AddTpToWorkouts < ActiveRecord::Migration
  def self.up
    add_column :workouts, :trackpoints, :string
  end

  def self.down
    remove_column :workouts, :trackpoints
  end
end
