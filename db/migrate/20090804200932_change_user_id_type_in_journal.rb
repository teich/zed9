class ChangeUserIdTypeInJournal < ActiveRecord::Migration
  def self.up
    change_column :journal_entries, :user_id, :integer
  end

  def self.down
    change_column :journal_entries, :user_id, :string
  end
end
