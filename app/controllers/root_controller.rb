class RootController < ApplicationController

	def index

		# list of most recent public workouts
		@workouts = Workout.find_all_by_shared(true, :limit=>8, :order => "updated_at DESC")

		@user_session = UserSession.new

		if current_user
			redirect_to dashboard_path
		end

	end

end
