class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.timestamp :start_time
      t.float :distance
      t.integer :average_hr
      t.timestamp :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
