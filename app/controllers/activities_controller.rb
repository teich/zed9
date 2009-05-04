class ActivitiesController < ApplicationController
  acts_as_tree :order => "name"
  
	def index
	  @activities = Activity.find(:all)
	  respond_to do |fmt|
      fmt.js { render :json => @activities.to_json(:only => [:id, :name] )}
    end
	end
end
