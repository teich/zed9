require 'authlogic'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	#helper :all # include all helpers, all the time

	include ArrayMath

	filter_parameter_logging :password, :password_confirmation
	helper_method :current_user_session, :current_user

	before_filter :create_user_session
	before_filter :set_user_time_zone

	private

	# Returns true or false if the user is logged in.
	# Preloads @current_user with the user model if they're logged in.
	def logged_in?
		!!current_user
	end

	def current_user_session
		return @current_user_session if defined?(@current_user_session)
		@current_user_session = UserSession.find
	end

	def set_user_time_zone
		Time.zone = current_user.time_zone if logged_in?
	end

	def current_user
		return @current_user if defined?(@current_user)
		@current_user = current_user_session && current_user_session.user
	end

	def require_user
		unless current_user
			store_location
			flash[:notice] = "You must be logged in to access this page"
			redirect_to new_user_session_url
			return false
		end
	end

	def require_no_user
		if current_user
			store_location
			flash[:notice] = "You must be logged out to access this page"
			redirect_to root_url
			return false
		end
	end

	def store_location
		session[:return_to] = request.request_uri
	end

	def redirect_back_or_default(default)
		redirect_to(session[:return_to] || default)
		session[:return_to] = nil
	end

	def create_user_session
		if !logged_in?
			@user_session = UserSession.new
		end
	end

	def require_admin
		unless current_user && current_user.admin_user?
			flash[:notice]= "You don't have permission to view this page"
			redirect_to root_url
			return false
		end
	end
end
