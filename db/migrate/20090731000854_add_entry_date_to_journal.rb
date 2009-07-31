class AddEntryDateToJournal < ActiveRecord::Migration
  def self.up
    add_column :journal, :entry_date, :date
  end

  def self.down
    remove_column :journal, :entry_date
  end
end
