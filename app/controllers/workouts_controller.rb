require 'hpricot'

class WorkoutsController < ApplicationController
  before_filter :require_user, :except => [:show, :index]

  before_filter :find_workout, :only => [:edit, :update, :destroy, :merge]
  before_filter :find_and_bounce, :only => [:show]
  before_filter :find_user_and_require_shared, :only => [:index]
  before_filter :upload_if_no_workouts, :only => [:index]

  def index

    # TODO: DRY
    if my_page?
      if params[:tag]
        @workouts = @user.workouts.find_tagged_with(params[:tag]).paginate :page => params[:page], :per_page => 100
      else
        @workouts = @user.workouts.find(:all, :order => "start_time DESC").paginate :page => params[:page], :per_page => 100
      end

    else
      if params[:tag]
        @workouts = @user.workouts.find_tagged_with(params[:tag]).paginate :page => params[:page], :per_page => 100
      else
        @workouts = @user.workouts.find_all_by_shared(true, :order => "start_time DESC").paginate :page => params[:page], :per_page => 100
      end

    end

    respond_to do |format|
      format.html
      format.xml {render :xml => @workouts.to_xml }
    end

  end

  def show

    # need for creating new tags.  
    @tagging = Tagging.new

    @rpe = RPE.new

    @workouts_nearby = @workout.workouts_nearby

    respond_to do |format|
      format.html
      format.xml {render :xml => @workout.to_xml }
      format.js {render :js => @workout.to_json(:methods => [:json_hr, :json_heartrate_big, :json_speed, :json_speed_big, :json_elevation, :json_elevation_big, :gis, :cals], :except => :trackpoints, :include => [:activity, :user])}
    end
  end

  def new
    @rpe = RPE.new
    @workout = current_user.workouts.build
    @workout.set_defaults!
    # setup one device for form.
    @workout.devices.build
  end

  def edit
    @rpe = RPE.new
  end

  def create
    @rpe = RPE.new
    @workout = current_user.workouts.create(params[:workout])
    @workout.importing = true if !@workout.manual_entry?
    if !@workout.gear.nil?
      @workout.tag_list << @workout.gear.tag
    end
    if @workout.save
      if @workout.manual_entry?
        add_flash(:notice, "Sucessfully created your manual workout")
      else
        Delayed::Job.enqueue WorkoutJob.new(@workout.id)
        # @workout.perform
        add_flash(:notice, 'Now processing your workout data... This may take a minute.')
      end
      redirect_to user_workouts_path(current_user)
    else
      @workout.destroy
      render :action => "new"
    end
  end

  def update

    if @workout.update_attributes(params[:workout])
      @workout.clear_gear_tags
      if !@workout.gear.nil?
        @workout.tag_list << @workout.gear.tag
        @workout.save
      end
      add_flash(:notice, 'Workout updated')
      redirect_to @workout
    else
      render :action => "edit"
    end

  end


  def destroy
    # Destroying here so that the merge can call .destroy on a workout
    @workout.trackpoints.delete_all
    @workout.devices.destroy_all
    @workout.destroy
    redirect_to(user_workouts_url(current_user))
  end

  private

  def find_workout
    @workout = current_user.workouts.find(params[:id])
  end    

  def find_and_bounce
    @workout = Workout.find(params[:id])

    if (!@workout.shared && !current_user.nil? && (@workout.user_id != current_user.id))
      add_flash(:alert, "This workout is private")
      redirect_to root_path 
    end
  end

  def find_user_and_require_shared
    @user = User.find_by_login(params[:user_id])

    if @user.nil? || !(!current_user.nil? && current_user.id == @user.id) && !@user.shared
      add_flash(:alert, "This page is private")
      redirect_to root_path
    end
  end

  def upload_if_no_workouts
    redirect_to new_user_workout_path(current_user) if my_page? && current_user.workouts.size == 0 
  end

end
