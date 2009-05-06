class ActivitiesController < ApplicationController
	before_filter :require_admin, :except => :index

	before_filter :find_activity, :only => [:edit, :update, :destroy]


	def index
		@activities = Activity.find(:all)
		respond_to do |fmt|
			fmt.js { render :json => @activities.to_json(:only => [:id, :name] )}
		end
	end

	def create
		@activity = Activity.new(params[:activity])
		if @activity.save
			redirect_to admin_activities_path
		else
			render :action => :new
		end		
	end

	def update
		if @activity.update_attributes(params[:activity])
			flash[:notice] = 'Activity updated.'
			redirect_to admin_activities_path
		else
			render :action => "edit"
		end
	end

	def destroy
		@activity.destroy
		flash[:notice] = 'Destroyed activity.  Mwuhahaha.'
		redirect_to admin_activities_path
	end

	def find_activity
		@activity = Activity.find(params[:id])
	end
end
