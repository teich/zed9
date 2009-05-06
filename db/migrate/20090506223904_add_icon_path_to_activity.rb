class AddIconPathToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :icon_path, :string
  end

  def self.down
    remove_column :activities, :icon_path
  end
end
