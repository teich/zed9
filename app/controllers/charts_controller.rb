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
    chart = Ziya::Charts::Mixed.new '', 'hr_graph'
    chart.add :chart_types, %w[area area area line]
    
    @workout = current_user.workouts.find(params[:workout_id])
    hr_series = @workout.get_hr
    graph_data = smooth_data(hr_series, 10)
    
    hr1 = []
    hr2 = []
    hr3 = []
    axis = []
    
    graph_data.length.times do |x|
      hr1 << 100
      hr2 << 150
      hr3 << 180
      axis << x
    end
    chart.add :axis_category_text, axis 
    chart.add :series, "", hr1
    chart.add :series, "", hr2
    chart.add :series, "", hr3
    chart.add :series, "", graph_data 
    chart.add :theme , "zed9"
    
    respond_to do |fmt|
      fmt.xml { render :xml => chart.to_xml }
    end
  end
  
  private

    def smooth_data(series, factor)
      res = []
      series.in_groups_of(factor) do |snipit|
        res << snipit.compact.average_array
      end
      res
    end


end
