class AddIndexesToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, :created_at
    add_index :workouts, :created_at
  end

  def self.down
    remove_index :comments, :created_at
    remove_index :workouts, :created_at
  end
end
