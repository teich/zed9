class AddUserIdToGears < ActiveRecord::Migration
  def self.up
    add_column :gears, :user_id, :integer
  end

  def self.down
    remove_column :gears, :user_id
  end
end
