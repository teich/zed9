class UsersController < ApplicationController

	before_filter :require_no_user, :only => [:new, :create]
	before_filter :require_user, :only => [:show, :edit, :update]

	def new
		@user = User.new(:invitation_token => params[:invitation_token])
		@user.email = @user.invitation.recipient_email if @user.invitation
	end

	def create
		@user = User.new(params[:user])
		if @user.save
			flash[:notice] = "Thanks for setting up your account!<br>Next step: upload a workout."
			redirect_to new_user_workout_path(@user)
		else
			render :action => :new
		end
	end

	def show
		@user = User.find_by_login(params[:id])
	end

	def edit
		@user = @current_user
	end

	def update
		@user = @current_user # makes our views "cleaner" and more consistent
		if @user.update_attributes(params[:user])
			flash[:notice] = "Account updated!"
			redirect_to account_url
		else
			render :action => :edit
		end
	end
end
