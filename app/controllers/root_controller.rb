class RootController < ApplicationController
  def index
    @user_session = UserSession.new
    
    if current_user
      redirect_to user_workouts_path(current_user)
    end
  end
end
