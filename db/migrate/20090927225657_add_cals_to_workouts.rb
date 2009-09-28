class AddCalsToWorkouts < ActiveRecord::Migration
  def self.up
    add_column :workouts, :calories, :integer
  end

  def self.down
    remove_column :workouts, :calories
  end
end
