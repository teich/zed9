require 'scruffy'

class ChartsController < ApplicationController
  def show
    @workout = current_user.workouts.find(params[:workout_id])
    hr_series = @workout.trackpoints.map {|a|a.heart_rate}

    res = smooth_data(hr_series, 25)    

    graph = Scruffy::Graph.new(:theme => Scruffy::Themes::Mephisto.new)
    graph.add(:line, 'Heart Rate', res)
    send_data(graph.render(:width => 400, :as => 'PNG'), :type => 'image/png', :disposition=> 'inline')
  end
  
  private

    def smooth_data(series, factor)
      res = []
      splits = series.length / factor
      logger.debug "Averaging #{series.length} trackpoints down to #{splits}"
      
      splits.times do |x|
        first = x * factor
        last = (x + 1) * factor
        
        # logger.debug "Array indicies: #{first} - #{last}"
        
        sum = 0
        datapoints = 0
        snipit = series[first..last]
        next if snipit.nil?

        snipit.length.times do |i|
          next if snipit[i].nil?
          sum += snipit[i]
          datapoints += 1
        end
        avg = sum.to_f / datapoints
        res << avg
      end
      res
    end

end
