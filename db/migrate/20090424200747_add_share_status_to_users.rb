class AddShareStatusToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :shared, :boolean, :default => 0
  end

  def self.down
    remove_column :users, :shared
  end
end
