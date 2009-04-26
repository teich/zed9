class ChartsController < ApplicationController

  XMLSWF = "KTQ0A419J7YULQZ0B6SVMYWHM5SXBL"
  
  def workout_heart_rate
    chart = Ziya::Charts::Line.new XMLSWF, 'hr_graph'

    @workout = Workout.find(params[:workout_id])

    chart.add :axis_category_text, @workout.get_smoothed_and_formated_hr_axis(200)
    chart.add :series, "HR", @workout.get_smoothed_hr(200)
    chart.add :theme , "zed9"

    respond_to do |fmt|
      fmt.xml { render :xml => chart.to_xml }
    end
  end

  def dashboard_duration_data
    chart = Ziya::Charts::Column.new XMLSWF, 'dashboard_duration'
    @workouts = current_user.workouts.find(:all, :order => "start_time")
    chart.add :axis_category_text, @workouts.map { |w| w.start_time.strftime("%a\n%b %d") }
    chart.add :series, "Duration\nminutes", @workouts.map { |w| w.duration / 60 }
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
