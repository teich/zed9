class Admin::UsersController < ApplicationController
	before_filter :require_admin

	def index
		@users = User.find(:all)
		
		@invited = Invitation.find(:all, :conditions => ['sent_at > ?', 10.year.ago])
		
		@waiting = Invitation.find_all_by_sender_id(nil)
		
		
	end

end