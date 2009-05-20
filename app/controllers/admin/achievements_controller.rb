class Admin::AchievementsController < ApplicationController
	before_filter :find_achievements, :only => [:update, :edit, :show, :destroy]
	
	def index
		@achievements = Achievement.find(:all)
	end
	
	def create
		@achievement = Achievement.new(params[:achievement])
		if @achievement.save
			redirect_back_or_default admin_achievements_path
		else
			render :action => :new
		end
	end
	
	def update
		if @achievement.update_attributes(params[:achievement])
			flash[:notice] = 'Achievement updated.'
			redirect_to admin_achievements_path
		else
			render :action => "edit"
		end	
	end
	
	def destroy
		@achievement.destroy
		redirect_to admin_achievements_path
	end
	
	def find_achievements
		@achievement = Achievement.find(params[:id])
	end
end