class ActivitiesController < ApplicationController
	before_filter :require_admin, :except => [:index, :show]

	before_filter :find_activity, :only => [:edit, :update, :destroy, :show]

	def show
		@longest = @activity.workouts.find(:all, :conditions => "start_time > \"#{7.days.ago}\"", :order => "duration DESC", :limit => 5)
		@fastest = @activity.workouts.find(:all, :conditions => "speed > 0 AND start_time > \"#{7.days.ago}\"", :order => "speed DESC", :limit => 5)
		@climbers = @activity.workouts.find(:all, :conditions => "elevation > 0 AND start_time > \"#{7.days.ago}\"", :order => "elevation DESC", :limit => 5)
		@farthest = @activity.workouts.find(:all, :conditions => "distance > 0 AND start_time > \"#{7.days.ago}\"", :order => "distance DESC", :limit => 5)
		@heart_pumping = @activity.workouts.find(:all, :conditions => "hr > 0 AND start_time > \"#{7.days.ago}\"", :order => "hr DESC", :limit => 5)

    # list of most recent public workouts
    @shared = @activity.workouts.find_all_by_shared(true, :limit=>12, :order => "updated_at DESC")

	end

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
		flash[:notice] = 'Destroyed activity.  Mwahahaha.'
		redirect_to admin_activities_path
	end

	def find_activity
		@activity = Activity.find(params[:id])
	end
end
