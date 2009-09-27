class CreateAverages < ActiveRecord::Migration
  def self.up
    create_table :averages do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :averages
  end
end
