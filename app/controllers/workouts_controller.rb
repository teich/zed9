require 'hpricot'
require 'scruffy'

class WorkoutsController < ApplicationController  
 
  # REQUIRE LOGIN
  before_filter :login_required
 
  #  include Ziya
  #helper Ziya::Helper 
  
  before_filter :find_workout, :only => [:show, :edit, :update, :destroy, :scruffy_image]

  def index
    @workouts = current_user.workouts.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @workout }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @workout }
    end
  end

  def new
    @workout = current_user.workouts.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @workout }
    end
  end

  def edit
  end

  def create
    @workout = current_user.workouts.build
    #@activity.update_attributes(params[:activity])

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

    respond_to do |format|
      if @workout.save
        flash[:notice] = 'Workout was successfully created.'
        format.html { redirect_to(@workout) }
        format.xml  { render :xml => @workout, :status => :created, :location => @workout }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @workout.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @workout.update_attributes(params[:workout])
        flash[:notice] = 'Workout was successfully updated.'
        format.html { redirect_to(@workout) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @workout.errors, :status => :unprocessable_entity }
      end
    end
  end


  def destroy
    @workout.destroy

    respond_to do |format|
      format.html { redirect_to(workouts_url) }
      format.xml  { head :ok }
    end
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
  
  def smooth_data(series, factor)
    res = []
    (0...series.length).step(factor) {|x| res << series[x]}
    res
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
