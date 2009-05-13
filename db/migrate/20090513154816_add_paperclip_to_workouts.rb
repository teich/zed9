class AddPaperclipToWorkouts < ActiveRecord::Migration
  def self.up
		add_column :workouts, :source_file_name, :string
		add_column :workouts, :source_content_type, :string
		add_column :workouts, :source_file_size, :integer
		add_column :workouts, :source_updated_at, :datetime
		add_column :workouts, :source_processed_at, :datetime
  end

  def self.down
		remove_column :workouts, :source_processed_at
		remove_column :workouts, :source_updated_at
		remove_column :workouts, :source_file_size
		remove_column :workouts, :source_content_type
		remove_column :workouts, :source_file_name
  end
end
