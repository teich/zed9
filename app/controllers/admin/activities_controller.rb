class Admin::ActivitiesController < ApplicationController
  before_filter :require_admin
  
  def index
    @users = User.find(:all)
  end
  
end