class CreateTrackpoints < ActiveRecord::Migration
  def self.up
    create_table :trackpoints do |t|
      t.float :latitude
      t.float :longitutde
      t.integer :heart_rate
      t.references :activity

      t.timestamps
    end
  end

  def self.down
    drop_table :trackpoints
  end
end
