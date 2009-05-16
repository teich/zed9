class AddNotesToWorkouts < ActiveRecord::Migration
  def self.up
		add_column :workouts, :notes, :string
  end

  def self.down
		remove_column :workouts, :notes
  end
end
