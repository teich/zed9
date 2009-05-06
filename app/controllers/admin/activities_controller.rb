class Admin::ActivitiesController < ApplicationController
  before_filter :require_admin
  
  def index
    @activities = Activity.find_all_by_parent_id(nil)

	@activity = Activity.new
  end
  
end