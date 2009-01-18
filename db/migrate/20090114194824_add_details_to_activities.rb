class AddDetailsToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :name, :string
    add_column :activities, :type, :string
  end

  def self.down
    remove_column :activities, :type
    remove_column :activities, :name
  end
end
