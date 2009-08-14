class RootController < ApplicationController

	def index

		# list of most recent public workouts

		@workouts = Workout.processed.find_all_by_shared(true, :order => "created_at DESC")
    @comments = Comment.find(:all, :order => "created_at DESC")
    entries = @workouts + @comments
    @activity_feed = entries.sort { |a,b| b.created_at <=> a.created_at } .paginate :page => params[:page], :per_page => 4

		@user_session = UserSession.new

		if current_user
			redirect_to dashboard_path
		end

	end

end
