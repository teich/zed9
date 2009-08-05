class AddDefaultsToGearUsage < ActiveRecord::Migration
  def self.up
    change_column_default :gears, :distance_used, "0"
    change_column_default :gears, :hours_used, "0"
  end

  def self.down
    change_column_default :gears, :hours_used, ""
    change_column_default :gears, :distance_used, ""
  end
end
