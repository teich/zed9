class ChangeHoursMaxToFloatInGears < ActiveRecord::Migration
  def self.up
    change_column :gears, :hours_max, :float
  end

  def self.down
    change_column :gears, :hours_max, :time
  end
end
