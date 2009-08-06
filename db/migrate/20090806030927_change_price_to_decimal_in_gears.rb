class ChangePriceToDecimalInGears < ActiveRecord::Migration
  def self.up
    change_column :gears, :price, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    change_column :gears, :price, :float
  end
end
