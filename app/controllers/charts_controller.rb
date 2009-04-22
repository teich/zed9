# require 'scruffy'

class ChartsController < ApplicationController
  
#  def show
#    @workout = current_user.workouts.find(params[:workout_id])
#    hr_series = @workout.trackpoints.map {|a|a.heart_rate}

#    res = smooth_data(hr_series, 40)    

#    graph = Scruffy::Graph.new(:theme => Scruffy::Themes::Mephisto.new)
#    graph.add(:line, 'Heart Rate', res)
#    send_data(graph.render(:width => 400, :as => 'PNG'), :type => 'image/png', :disposition=> 'inline')
#  end
 
  def show
    chart = Ziya::Charts::Line.new '', 'hr_graph'
    
    @workout = current_user.workouts.find(params[:workout_id])
    hr_series = @workout.get_hr
    graph_data = smooth_data(hr_series, 10)
    

    # TODO: use getter fuctions.  Need to be defined in workout model still
    chart.add :axis_category_text, @workout.get_hr_axis
    # chart.add :series, "ZR", @workout.get_hr.map {|hr| hr/3 }
    #     chart.add :series, "MR", @workout.get_hr.map {|hr| hr/2 }
    chart.add :series, "HR", @workout.get_hr
    chart.add :theme , "zed9"
    
    respond_to do |fmt|
      fmt.xml { render :xml => chart.to_xml }
    end
  end
  
  private

    def smooth_data(series, factor)
      series.in_groups_of(factor).map { |snipit| snipit.compact.average_array }
    end


end
