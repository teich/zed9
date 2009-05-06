class Admin::ActivitiesController < ApplicationController
  before_filter :require_admin
  
  def index
    @activities = Activity.find_all_by_parent_id(nil)
	files = Dir.glob("public/images/activities/*")
	@icons = files.map{|f| f.gsub(/public/, '')}
	@activity = Activity.new
  end
  
end