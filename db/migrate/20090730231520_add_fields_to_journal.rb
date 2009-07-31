class AddFieldsToJournal < ActiveRecord::Migration
  def self.up
    add_column :journal, :user_id, :string
    add_column :journal, :updated_at, :datetime 
  end

  def self.down
    remove_column :journal, :user_id
    remove_column :journal, :updated_at
  end
end
