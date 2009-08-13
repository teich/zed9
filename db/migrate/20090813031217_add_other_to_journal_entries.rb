class AddOtherToJournalEntries < ActiveRecord::Migration
  def self.up
    add_column :journal_entries, :other, :text, :limit => 255
  end

  def self.down
    remove_column :journal_entries, :other
  end
end
