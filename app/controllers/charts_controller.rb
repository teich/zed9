class ChartsController < ApplicationController
  
  def show
    chart = Ziya::Charts::Line.new '', 'hr_graph'
    
    @workout = current_user.workouts.find(params[:workout_id])
    
    chart.add :axis_category_text, @workout.get_hr_axis
    chart.add :series, "HR", @workout.get_hr
    chart.add :theme , "zed9"
    
    respond_to do |fmt|
      fmt.xml { render :xml => chart.to_xml }
    end
  end
  
  def dashboard_duration_data
    chart = Ziya::Charts::Column.new '', 'dashboard_duration'
    @workouts = current_user.workouts.find(:all, :order => "start_time")
    chart.add :axis_category_text, @workouts.map { |w| w.start_time.strftime("%D") }
    chart.add :series, "Duration", @workouts.map { |w| w.duration }
    chart.add :theme, "zed9"
    respond_to do |fmt|
      fmt.xml { render :xml => chart.to_xml }
    end
  end
  
  private

    def smooth_data(series, factor)
      series.in_groups_of(factor).map { |snipit| snipit.compact.average_array }
    end


end
