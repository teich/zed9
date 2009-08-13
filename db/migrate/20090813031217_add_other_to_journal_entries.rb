class AddOtherToJournalEntries < ActiveRecord::Migration
  def self.up
    add_column :journal_entries, :other, :text
  end

  def self.down
    remove_column :journal_entries, :other
  end
end
