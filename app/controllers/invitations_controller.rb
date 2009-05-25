class InvitationsController < ApplicationController
  after_filter :check_achievements, :only => [:create]
  
	def new
		@invitation = Invitation.new
	end

	def create
		@invitation = Invitation.new(params[:invitation])
		@invitation.sender = current_user
		if @invitation.save
			if logged_in?
				Mailer.deliver_invitation(@invitation, signup_url(@invitation.token))
				add_flash(:notice, "Invitation sent!")
				redirect_to dashboard_url
			else
				add_flash(:notice, "Thanks for putting your name on the list! We will email you an invitation as soon as we have a spot open in the beta.")
				redirect_to root_url
			end
		else
			render :action => 'new'
		end
	end
	
	
  def check_achievements
    if logged_in?
    	achievements = Achievement.find(:all, :conditions => ['controller = ? AND action = ?', params[:controller], params[:action]])
    	achievements.each do |a|
    		if eval a.logic and !current_user.awarded?(a)
    			current_user.award(a)
    			add_flash(:achievement, "You've earned a new achievement: #{a.name}")
    		end
    	end
    end
  end
end
