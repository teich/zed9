class TaggingsController < ApplicationController
	before_filter :find_workout

	def destroy
		tag = @workout.taggings.find(:first, :conditions => "tag_id = #{params[:id]}")
		tag.destroy
		add_flash(:notice, 'Tag destroyed. Mwahahaha.')
		redirect_to @workout
	end

	def create
		@workout.tag_list << params[:name]
		@workout.save
		add_flash(:notice, "Added tag #{params[:name]}")
		redirect_to @workout
	end

	private

	def find_workout
		@workout = Workout.find(params[:workout_id])
		#    @tagging = Tagging.find(params[:id])
	end

end
