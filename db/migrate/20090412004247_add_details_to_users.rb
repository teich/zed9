class AddDetailsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :birthdate, :date
    add_column :users, :sex, :string
    add_column :users, :height, :integer
  end

  def self.down
    remove_column :users, :height
    remove_column :users, :sex
    remove_column :users, :birthdate
  end
end
