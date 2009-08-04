class CreateJournal < ActiveRecord::Migration
  def self.up
    create_table :journal_entries do |t|
      t.float   :weight
      t.integer :user_id
      t.float   :vo2
      t.date    :entry_date
      
      t.timestamps
    end
  end

  def self.down
    drop_table :journal_entries
  end
end