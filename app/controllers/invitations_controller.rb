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
				flash[:notice] = "Thanks for putting your name on the list!<br>We will email you an invitation as soon as we have a spot open in the beta."
				redirect_to root_url
			end
		else
			render :action => 'new'
		end
	end
end
