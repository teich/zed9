class RootController < ApplicationController
  def index
    @user_session = UserSession.new
    
    if current_user
      redirect_to workouts_path
    end
  end
end
