class AddVo2ToJournalEntries < ActiveRecord::Migration
  def self.up
    add_column :journal_entries, :vo2, :integer
  end
  
  def self.down
    remove_column :journal_entries, :vo2
  end
end
