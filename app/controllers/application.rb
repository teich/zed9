# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authorize, :except => :login
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => 'ddb7675640c301d0d697667f75eabe7b'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  LICENSE = ""
  
  protected
    def authorize
      unless User.find_by_id(session[:user_id])
        session[:original_uri] = request.request_uri
        flash[:notice] = "Please log in"
        redirect_to :controller => 'users' , :action => 'login'
      end
    end
end
