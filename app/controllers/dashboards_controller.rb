class DashboardsController < ApplicationController
	before_filter :require_user

	def show
		@workouts = current_user.workouts.find(:all, :order => "start_time")

		# list of most recent public workouts
		@shared = Workout.find_all_by_shared(true, :limit=>8, :order => "updated_at DESC")

		durations = @workouts.map { |w| w.duration }
		if durations.nil?
			@total_time = 0
		else
			@total_time = durations.compact.asum
		end

		# TODO: pull out of controller!
		# figure out how much time users spend on average working out.  ick.
		users = User.find(:all)
		aud = users.map do |u|
			uw = u.workouts.find(:all)
			uwd = uw.map { |uwm| uwm.duration }
			if uwd.nil?
				utt = 0
			else
				utt = uwd.compact.asum
			end
		end 
		@atd = aud.aaverage

		respond_to do |format|
			format.html
			format.js {render :js => @workouts.to_json(:methods => [:json_date, :activity_name]) }
		end
	end
end
