require 'hpricot'

class WorkoutsController < ApplicationController
  before_filter :require_user
  
  before_filter :find_workout, :only => [:show, :edit, :update, :destroy]
  
  def index
    @workouts = current_user.workouts.find(:all)
  end

  def show
  end

  def new
    @workout = current_user.workouts.build
  end

  def edit
  end

  def create
    @workout = current_user.workouts.build

    # Need to parse the XML seperatly here.  
    # TODO: Generize this to support any file.
    uploaded_file = params[:device_file] 
    data = uploaded_file.read if uploaded_file.respond_to? :read 
    if request.post? and data  
      @points = parse_garmin_xml( data ) 
      @points.each do |p|
        @workout.trackpoints.build(p)
      end
    end

    if @workout.save
      flash[:notice] = 'Workout was successfully created.'
      redirect_to [current_user, @workout]
    else
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

    def parse_garmin_xml ( xml_data )
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

    def load_chart
      @workout = Workout.find(params[:id])

      hr_series = []
      time_series = []
      c = 1
      @workout.trackpoints.each do |a|
        next if a.heart_rate == nil
        hr_series << a.heart_rate
        time_series << c
        c += 1 
      end

      chart = Ziya::Charts::Line.new LICENSE, 'sparse_line'
      chart.add( :theme, "fitness" )
      chart.add :axis_category_text, time_series 
      chart.add :series, "HR", hr_series

      respond_to do |fmt|
        fmt.xml { render :xml => chart.to_xml }
      end
    end

    def scruffy_image
      hr_series = @workout.trackpoints.map {|a|a.heart_rate}

      res = smooth_data(hr_series, 15)

      graph = Scruffy::Graph.new(:theme => Scruffy::Themes::Mephisto.new)
      graph.add(:line, 'Heart Rate', res)
      send_data(graph.render(:width => 400, :as => 'PNG'), :type => 'image/png', :disposition=> 'inline')  
    end

    def is_garmin?
      params[:device] == "garmin"
    end


    
    
end
