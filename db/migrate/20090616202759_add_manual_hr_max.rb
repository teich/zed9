class AddManualHrMax < ActiveRecord::Migration
  def self.up
    add_column :workouts, :hr_max, :integer
  end

  def self.down
    remove_column :workouts, :hr_max
  end
end
