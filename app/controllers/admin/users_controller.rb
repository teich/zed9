class Admin::UsersController < ApplicationController
  before_filter :require_admin
  
  def index
    @users = User.find(:all)
    @invitations = Invitation.find(:all)
  end
  
end