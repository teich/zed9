class InvitationsController < ApplicationController
	def new
		@invitation = Invitation.new
	end

	def create
		@invitation = Invitation.new(params[:invitation])
		@invitation.sender = current_user
		if @invitation.save
			if logged_in?
				Mailer.deliver_invitation(@invitation, signup_url(@invitation.token))
				flash[:notice] = "Thank you. Invitation sent!"
				redirect_to dashboard_url
			else
				flash[:notice] = "Thank you. We will notify you when we are ready."
				redirect_to root_url
			end
		else
			render :action => 'new'
		end
	end
end
