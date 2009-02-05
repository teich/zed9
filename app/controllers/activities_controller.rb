require 'hpricot'
require 'scruffy'

class ActivitiesController < ApplicationController  
 
  # REQUIRE LOGIN
  before_filter :login_required
 
  #  include Ziya
  #helper Ziya::Helper 
  
  before_filter :find_activity, :only => [:show, :edit, :update, :destroy, :scruffy_image]
  # GET /activities
  # GET /activities.xml
  def index
    @activities = current_user.activities.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activities }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity }
    end
  end

  def new
    @activity = current_user.activities.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity }
    end
  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities
  # POST /activities.xml
  def create
    @activity = current_user.activities.build
    @activity.update_attributes(params[:activity])

    respond_to do |format|
      if @activity.save
        flash[:notice] = 'Activity was successfully created.'
        format.html { redirect_to(@activity) }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /activities/1
  # PUT /activities/1.xml
  def update
    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        flash[:notice] = 'Activity was successfully updated.'
        format.html { redirect_to(@activity) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.xml
  def destroy
    @activity.destroy

    respond_to do |format|
      format.html { redirect_to(activities_url) }
      format.xml  { head :ok }
    end
  end

  def find_activity
    @activity = current_user.activities.find(params[:id])
  end
  
  def upload 
    uploaded_file = params[:xml_file] 
    data = uploaded_file.read if uploaded_file.respond_to? :read 
    if request.post? and data  
      @activity = current_user.activities.build
      @activity.update_attributes( {"name" => "TEST TEST"})

      @points = parse_garmin_xml( data ) 
      @points.each do |p|
        @activity.trackpoints.build(p).save
      end
    else 
      redirect_to :action => 'index' 
    end
    
    
#    return render :text => "DEBUG #{@activity}"
  end 

  def parse_garmin_xml ( xml_data )
    doc = Hpricot::XML( xml_data ) 
    datapoint = []
    hr = 0
    (doc/:Trackpoint).each do |t| 
      hr = (t/:HeartRateBpm/:Value).innerHTML
      lat = (t/:Position/:LatitudeDegrees).innerHTML
      long = (t/:Position/:LongitudeDegrees).innerHTML

# Need to add migration to support these.      
#      time = (t/:Time).innerHTML
#      dist = (t/:DistanceMeters).innerHTML
#      alt = (t/:AltitudeMeters).innerHTML
      datapoint << { "heart_rate" => hr, "latitude" => lat, "longitude" => long }
    end
    return datapoint
  end
  
  def load_chart
    @activity = Activity.find(params[:id])
     
    hr_series = []
    time_series = []
    c = 1
    @activity.trackpoints.each do |a|
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
    # Slick one-line ruby hash->array thing
    hr_series = @activity.trackpoints.map {|a|a.heart_rate}
 
    # create a less dense array
    res = [] 
    (0...hr_series.length).step(10) {|x| res << hr_series[x]}
 
    graph = Scruffy::Graph.new(:theme => Scruffy::Themes::Mephisto.new)
    graph.add(:line, 'Heart Rate', res)
    send_data(graph.render(:width => 400, :as => 'PNG'), :type => 'image/png', :disposition=> 'inline')  
  end

end
