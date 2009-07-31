class CreateJournal < ActiveRecord::Migration
  def self.up
    create_table :journal do |t|
      t.datetime :created_at
      t.integer :weight 
    end
  end

  def self.down
    drop_table :journal
  end
end