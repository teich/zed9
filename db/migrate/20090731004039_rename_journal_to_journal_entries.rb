class RenameJournalToJournalEntries < ActiveRecord::Migration
  def self.up
    rename_table :journal, :journal_entries
  end

  def self.down
    rename_table :journal_entries, :journal
  end
end
