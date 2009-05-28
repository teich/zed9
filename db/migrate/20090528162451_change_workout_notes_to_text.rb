class ChangeWorkoutNotesToText < ActiveRecord::Migration
  def self.up
    change_column :workouts, :notes, :text
  end

  def self.down
    change_column :workouts, :notes, :string
  end
end
