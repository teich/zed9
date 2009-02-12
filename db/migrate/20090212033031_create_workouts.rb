class CreateWorkouts < ActiveRecord::Migration
  def self.up
    create_table :workouts do |t|
      t.timestamp :start_time
      t.float     :distance
      t.integer   :average_hr
      t.integer   :duration
      t.string    :name, :default => 'Unnamed'
      t.integer   :user_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :workouts
  end
end
