class CreateGearsTable < ActiveRecord::Migration
  def self.up
    create_table :gears, :force => true do |t|
      t.integer :user_id
      t.string  :name
      t.string  :tag
      t.string  :make
      t.string  :model
      t.float   :price
      t.string  :store
      t.date    :purchase_date
      t.float   :distance_used, :default => "0"
      t.integer :distance_max
      t.float    :hours_used, :default => "0"
      t.time    :hours_max
      t.timestamps
    end
  end

  def self.down
    drop_table :gears
  end
end
