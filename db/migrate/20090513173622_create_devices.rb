class CreateDevices < ActiveRecord::Migration
	def self.up
		create_table :devices do |t|
			t.string :source_file_name
			t.string :source_content_type
			t.integer :source_file_size
			t.datetime :source_updated_at
			t.string :mfg
			t.string :model
			t.integer :workout_id
			t.timestamps
		end
	end

	def self.down
		drop_table :devices
	end
end
