class CreateAverages < ActiveRecord::Migration
  def self.up
    create_table :averages do |t|
      t.float :duration_per_day
      t.float :duration
      t.integer :workouts
      t.timestamps
    end
  end

  def self.down
    drop_table :averages
  end
end
