require 'scruffy'

class ChartsController < ApplicationController
  def show
    @workout = current_user.workouts.find(params[:workout_id])
    hr_series = @workout.trackpoints.map {|a|a.heart_rate}

    res = smooth_data(hr_series, 40)    

    graph = Scruffy::Graph.new(:theme => Scruffy::Themes::Mephisto.new)
    graph.add(:line, 'Heart Rate', res)
    send_data(graph.render(:width => 400, :as => 'PNG'), :type => 'image/png', :disposition=> 'inline')
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
