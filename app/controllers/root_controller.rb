class RootController < ApplicationController

	def index

		# list of most recent public workouts
		@public_workouts = Workout.processed.find_all_by_shared(true, :order => "created_at DESC").paginate :page => params[:page], :per_page => 8

		@user_session = UserSession.new

		if current_user
			redirect_to dashboard_path
		end

	end

end
