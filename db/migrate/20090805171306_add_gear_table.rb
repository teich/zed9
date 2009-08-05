class AddGearTable < ActiveRecord::Migration
  def self.up
    create_table :gear, :force => true do |t|
      t.string  :name
      t.string  :tag
      t.string  :make
      t.string  :model
      t.float   :price
      t.string  :store
      t.date    :purchase_date
      t.float   :distance_used
      t.integer :distance_max
      t.time    :hours_used
      t.time    :hours_max
      t.timestamps
    end
  end

  def self.down
    drop_table :gear
  end
end
