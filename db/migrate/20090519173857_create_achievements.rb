class CreateAchievements < ActiveRecord::Migration
  def self.up
    create_table :achievements do |t|
      t.string  :name
      t.string  :logic
      t.integer :precondition_id
      t.string  :controller
      t.string  :action
      t.string  :description
      t.integer :points
      t.string  :icon_path
      t.timestamps
    end
  end

  def self.down
    drop_table :achievements
  end
end
