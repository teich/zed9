class RenameGearToGears < ActiveRecord::Migration
  def self.up
    rename_table :gear, :gears
  end

  def self.down
    rename_table :gears, :gear
  end
end
