class CreateHrZones < ActiveRecord::Migration
  def self.up
    create_table :hr_zones do |t|
      t.integer   :user_id,     :null => false
      t.integer   :lower_limit, :null => false
      t.integer   :upper_limit, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :hr_zones
  end
end
