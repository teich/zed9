class Admin::UsersController < ApplicationController
	before_filter :require_admin

	def index
		@users = User.find(:all)
		
		@invited = Invitation.find(:all, :conditions => ['sent_at > ?', 10.year.ago])
		
		admin = User.find_all_by_admin(true)
		@invited_by_admin = Invitation.find_all_by_sender_id(admin)
    @admin_conversion = (@invited_by_admin.size / @invited.size).to_i

		@waiting = Invitation.find_all_by_sender_id(nil)
		
	end

end