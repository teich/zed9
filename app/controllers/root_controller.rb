class RootController < ApplicationController

  layout "public"
  
  def index
    @user_session = UserSession.new
    
    if current_user
      redirect_to dashboard_path
    end
  end
end
