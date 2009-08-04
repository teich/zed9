class ChangeJournalEntriesToFloat < ActiveRecord::Migration
  def self.up
    change_column :journal_entries, :weight, :float
    change_column :journal_entries, :vo2, :float
  end

  def self.down
    change_column :journal_entries, :vo2, :integer
    change_column :journal_entries, :weight, :integer
  end
end
