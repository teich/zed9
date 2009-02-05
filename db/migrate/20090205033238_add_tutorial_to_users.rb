class AddTutorialToUsers < ActiveRecord::Migration
  def self.up
		add_column :users, :user_type,        :string
		add_column :users, :identity_url,     :string
		add_column :users, :invitation_id,    :integer
		add_column :users, :invitation_limit, :integer
		add_column :users, :enabled,          :boolean, :default => true   
  end

  def self.down
    remove_column :users, :user_type
    remove_column :users, :identity_url
		remove_column :users, :invitation_id
		remove_column :users, :invitation_limit
		remove_column :users, :enabled
  end
end
