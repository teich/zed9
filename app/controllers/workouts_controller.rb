require 'hpricot'

class WorkoutsController < ApplicationController
  before_filter :require_user
  
  before_filter :find_workout, :only => [:show, :edit, :update, :destroy]
  
  def index
    if params[:tag]
      @workouts = current_user.workouts.tagged_with(params[:tag], :on => :tags)
    else
      @workouts = current_user.workouts.find(:all, :order => "start_time DESC")
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

    uploaded_file = params[:device_file] 
    if request.post? and uploaded_file.respond_to? :read
      
      # Version I'm running here seems to pass as string is <10K, or file if over.
      uploaded_data = ensure_string(uploaded_file)
      
      parsed_data = parse_polar( uploaded_data ) if is_polar?(params[:device])
      parsed_data = parse_garmin_xml( uploaded_data ) if is_garmin?(params[:device])

      @workout.update_attributes(:start_time => parsed_data["start_time"])

      points = parsed_data["datapoints"]
      points.each do |p|
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
      redirect_to(user_workouts_url)
    end

    
    private

    def find_workout
      @workout = current_user.workouts.find(params[:id])
    end    

    def parse_garmin_xml ( xml_data )
      doc = Hpricot::XML( xml_data ) 
      datapoints = []
      hr = 0
      start_time = (doc/:Id).innerHTML
      (doc/:Trackpoint).each do |t| 
        hr = (t/:HeartRateBpm/:Value).innerHTML
        lat = (t/:Position/:LatitudeDegrees).innerHTML
        long = (t/:Position/:LongitudeDegrees).innerHTML

  # TODO: Need to add migration to support these.      
  #      time = (t/:Time).innerHTML
  #      dist = (t/:DistanceMeters).innerHTML
  #      alt = (t/:AltitudeMeters).innerHTML
        datapoints << { "heart_rate" => hr, "latitude" => lat, "longitude" => long }
      end
      parsed_data = { "start_time" => start_time, "datapoints" => datapoints }
    end

    def parse_polar ( hrm_data )
      datapoints = []
      hr_data = 0
      date = ''
      start = ''
      parsed_data = {}
      
      hrm_array = hrm_data.split("\n")
      hrm_array.each do |line|
        line.chomp!
        datapoints << { "heart_rate" => line } if (hr_data == 1)

        if (line =~ /Date=(.*$)/)
          date = $1
        end
        if (line =~ /StartTime=(\d+):(\d+):(\d+)\..*$/)
          start = $1 + $2 + $3
        end
        if (line =~ /Monitor=(\d+$)/)
          parsed_data["device"] = $1
        end
        if (line =~ /\[HRData\]/)
          hr_data = 1
        end
      end
      start_time = date + start
      parsed_data = { "start_time" => start_time, "datapoints" => datapoints }
    end
    
    def is_garmin?(device)
      device == "garmin"
    end
    
    def is_polar?(device)
      device == "polar"
    end
    
    def ensure_string(uploaded_file)
      (uploaded_file.is_a?(String)) ? uploaded_file : uploaded_file.read
    end
end
