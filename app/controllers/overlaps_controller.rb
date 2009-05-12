class OverlapsController < ApplicationController
	before_filter :require_user

	before_filter :find_workout

	def index
		# Search for overlapping time that ISN'T us.
		@overlap = current_user.workouts.find(:all, :conditions => ['start_time <= ? AND end_time >= ? AND id != ?', @workout.end_time, @workout.start_time, @workout.id])
	end

	# We're destroying a duplicate, AKA merge it into the parent.
	def destroy
		## TODO: need to recaulate the duration somehow

		dup = current_user.workouts.find(params[:id])
		@workout.start_time = dup.start_time if (@workout.start_time > dup.start_time)
		@workout.end_time = dup.end_time if (@workout.end_time < dup.end_time)
		@workout.distance = dup.distance if (@workout.distance.nil?)
		@workout.duration = dup.duration if (@workout.duration < dup.duration)

		# Don't copy altitude if we already have one...
		# TODO - be smarter
		dup.trackpoints.each { |tp| tp.altitude = nil } if @workout.elevation > 0
		@workout.trackpoints += dup.trackpoints

		@workout.hr = @workout.calc_average_hr
		@workout.speed = @workout.calc_average_speed
		@workout.elevation = @workout.calc_altitude_gain

		@workout.save && dup.destroy
		flash[:notice] = 'Workouts successfully merged'
		redirect_to @workout

	end

	private 

	def find_workout
		@workout = current_user.workouts.find(params[:workout_id])
	end
end

