require 'hpricot'

class WorkoutsController < ApplicationController
  before_filter :require_user
  
  before_filter :find_workout, :only => [:show, :edit, :update, :destroy]
  
  def index
    if params[:tag]
      @workouts = current_user.workouts.tagged_with(params[:tag], :on => :tags)
    else
      @workouts = current_user.workouts.find(:all)
    end
  end

  def show
  end

  def new
    @workout = current_user.workouts.build
  end

  def edit
  end

  def create
    @workout = current_user.workouts.build(params[:workout])

    # Need to parse the XML seperatly here.  
    # TODO: Generize this to support any file.
    uploaded_file = params[:device_file] 
    if request.post? and uploaded_file.respond_to? :read  
      if (params[:device] == "polar")
        logger.debug "POLAR DEVICE"
        @points = parse_polar( uploaded_file )
      elsif (params[:device] == "garmin")
        logger.debug "GARMIN DEVICE"
        @points = parse_garmin_xml( uploaded_file ) 
      end
      @points.each do |p|
        @workout.trackpoints.build(p)
      end
    end
    
    if @workout.save
      flash[:notice] = 'Workout was successfully created.'
      redirect_to [current_user, @workout]
    else
      flash[:notice] = "can't save workout for some lame reason."
      render :action => "new"
    end
  end


    def update
      if @workout.update_attributes(params[:workout])
        flash[:notice] = 'Workout was successfully updated.'
        redirect_to([current_user, @workout])
      else
        render :action => "edit"
      end
    end


    def destroy
      @workout.destroy
      redirect_to(workouts_url)
    end

    def find_workout
      @workout = current_user.workouts.find(params[:id])
    end

    def parse_garmin_xml ( garmin_file )
      xml_data = garmin_file.read
      doc = Hpricot::XML( xml_data ) 
      datapoint = []
      hr = 0
      (doc/:Trackpoint).each do |t| 
        hr = (t/:HeartRateBpm/:Value).innerHTML
        lat = (t/:Position/:LatitudeDegrees).innerHTML
        long = (t/:Position/:LongitudeDegrees).innerHTML

  # TODO: Need to add migration to support these.      
  #      time = (t/:Time).innerHTML
  #      dist = (t/:DistanceMeters).innerHTML
  #      alt = (t/:AltitudeMeters).innerHTML
        datapoint << { "heart_rate" => hr, "latitude" => lat, "longitude" => long }
      end
      return datapoint
    end

    def parse_polar ( hrm_file )
      logger.debug "IN THE PARSE_POLAR FUNCTION!!!"
      datapoint = []
      hr_data = 0
      if (hrm_file.is_a?(String))
        hrm_string = hrm_file
      else
        hrm_string = hrm_file.read
      end
      hrm_array = hrm_string.split("\n")
      hrm_array.each do |line|
        datapoint << { "heart_rate" => line.chomp } if (hr_data == 1)
        if (line =~ /\[HRData\]/)
          hr_data = 1
        end
      end
      return datapoint
    end
    
    def is_garmin?
      params[:device] == "garmin"
    end


    
    
end
