require 'scruffy'

class ChartsController < ApplicationController
  def show
    @workout = current_user.workouts.find(params[:workout_id])
    hr_series = @workout.trackpoints.map {|a|a.heart_rate}

    res = smooth_data(hr_series, 15)

    graph = Scruffy::Graph.new(:theme => Scruffy::Themes::Mephisto.new)
    graph.add(:line, 'Heart Rate', res)
    send_data(graph.render(:width => 400, :as => 'PNG'), :type => 'image/png', :disposition=> 'inline')
  end
  
  private

    def smooth_data(series, factor)
      res = []
      (0...series.length).step(factor) {|x| res << series[x]}
      res
    end
end
