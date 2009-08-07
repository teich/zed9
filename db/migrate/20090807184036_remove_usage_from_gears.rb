class RemoveUsageFromGears < ActiveRecord::Migration
  def self.up
    remove_column :gears, :hours_used
    remove_column :gears, :distance_used
  end

  def self.down
    add_column :gears, :hours_used, :float
    add_column :gears, :distance_used, :float
  end
end
