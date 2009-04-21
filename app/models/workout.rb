class Workout < ActiveRecord::Base
  belongs_to  :users
  belongs_to  :activity
  has_many    :trackpoints

  validates_presence_of :name
  validates_length_of   :name,     :maximum => 100

  validates_presence_of :user_id

  acts_as_taggable_on   :tags

  def get_hr
    trackpoints.map {|a|a.heart_rate}
  end

  def calc_avg_hr
    get_hr.compact.average_array
  end

  def smooth_data(series, factor)
    series.in_groups_of(factor).map { |snipit| snipit.compact.average_array }
  end
  
  def get_hr_axis
    trackpoints.map { |tp| display_seconds(tp.time - start_time) }
  end
  
  def find_all_comps_by_activity(activity_id)
    @all_comps ||= Activity.find(activity_id).workouts
  end
  
  def find_user_comps_by_activity(user, activity_id)
    @my_comps ||= user.workouts.by_activity(activity_id)
  end

  # TODO: Refactor comparison code somehow
  def find_comps(user)
    all_comps = find_all_comps_by_activity(activity.id)
    my_comps = find_user_comps_by_activity(user, activity.id)
    return [my_comps, all_comps]
  end

  # TODO: The return nil check thing - seems lame
  def comps_average_hr(comps)
    if comps.size > 0
      hrs = comps.map { |comp| comp.calc_avg_hr }
      return hrs.compact.average_array
    end
    return "N/A"
  end

  def comps_average_duration(comps)
    if comps.size > 0
      duration = pick_array_field(comps, :duration)
      return duration.compact.average_array.round(1)
    end
    return "N/A"
  end

  # Take's an array of objects, and averages one field.
  def pick_array_field(data, field)
    data.map { |x| x[field] }
  end
  
  def display_seconds(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end
end
