class DashboardsController < ApplicationController
	before_filter :require_user

	def show
		@workouts = current_user.workouts.find(:all, :order => "start_time")

		# list of most recent public workouts
		@public_workouts = Workout.find_all_by_shared(true, :limit=>20, :order => "updated_at DESC")

    # recent achievements
    @accomplishments = Accomplishment.find_all_by_user_id(current_user, :conditions => ['created_at > ?', 7.days.ago])
    
		@farthest = current_user.workouts.find(:all, :conditions => ['distance > ?', 0], :order => "distance DESC", :limit => 5)
		@fastest = current_user.workouts.find(:all, :conditions => ['speed > ?', 0], :order => "speed DESC", :limit => 5)
		@longest = current_user.workouts.find(:all, :conditions => ['duration > ?', 0], :order => "duration DESC", :limit => 5)
		@climbers = current_user.workouts.find(:all, :conditions => ['elevation > ?', 0], :order => "elevation DESC", :limit => 5)
		@heart_pumping = current_user.workouts.find(:all, :conditions => ['hr > ?', 0], :order => "hr DESC", :limit => 5)

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
