class AddPaceToActivity < ActiveRecord::Migration
  def self.up
		add_column :activities, :pace, :boolean, :default => false
  end

  def self.down
		remove_column :activities, :pace
  end
end
