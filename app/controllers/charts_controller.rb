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
    chart = Ziya::Charts::Line.new '', 'sparse_line'
    
    @workout = current_user.workouts.find(params[:workout_id])
    hr_series = @workout.trackpoints.map {|a|a.heart_rate}
    graph_data = smooth_data(hr_series, 40)
    
    chart.add( :axis_category_text, %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25] )
    chart.add( :series, "", graph_data )
    
    respond_to do |fmt|
      fmt.xml { render :xml => chart.to_xml }
    end
  end
  
  private

    def smooth_data(series, factor)
      res = []
      series.in_groups_of(factor) do |snipit|
        sum = 0
        datapoints = 0

        # Yes, this is calculating the average of an array.  For shame
        snipit.length.times do |i|
          next if snipit[i].nil?
          sum += snipit[i]
          datapoints += 1
        end
        avg = sum.to_f / datapoints
        
        res << avg
#        res << snipit.average
      end
      res
    end


end
