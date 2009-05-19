class CreateAccomplishments < ActiveRecord::Migration
  def self.up
		create_table :accomplishments, :force => true do |t|
		  t.integer :workout_id
		  t.integer :achievement_id
		  t.timestamps
		end
  end

  def self.down
		drop_table :table_name
  end
end
