class Workout < ActiveRecord::Base
  belongs_to  :users
  has_many    :trackpoints
  belongs_to  :activity
  
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
  
  # TODO: The return nil check thing - seems lame
  def comps_average_hr
    comps = Workout.find_tagged_with(tag_list, :match_all => true)
    if comps.size > 0
      hrs = comps.map { |comp| comp.calc_avg_hr }
      return hrs.compact.average_array
    end
    return "N/A"
  end
  
  def comps_average_duration
    # Find comperables based on exact macthing all tags.
    comps = Workout.find_tagged_with(tag_list, :match_all => true)
    if comps.size > 0
      duration = pick_array_field(comps, :duration)
      duration.compact.average_array.round(1)
    end
    return "N/A"
  end

    def parse_garmin_xml ( xml_data )
      doc = Hpricot::XML( xml_data ) 
      datapoints = []
      hr = 0
      start_time = (doc/:Id).innerHTML
      duration = (doc/:TotalTimeSeconds).innerHTML
      (doc/:Trackpoint).each do |t| 
        hr = (t/:HeartRateBpm/:Value).innerHTML
        lat = (t/:Position/:LatitudeDegrees).innerHTML
        long = (t/:Position/:LongitudeDegrees).innerHTML

        datapoints << { "heart_rate" => hr, "latitude" => lat, "longitude" => long }
      end
      parsed_data = { "start_time" => start_time, "datapoints" => datapoints, "duration" => duration }
    end

    def parse_polar ( hrm_data )
      datapoints = []
      hr_data = 0
      date = ''
      start = ''
      parsed_data = {}
      duration = 0
      
      hrm_array = hrm_data.split("\n")
      hrm_array.each do |line|
        line.chomp!
        datapoints << { "heart_rate" => line } if (hr_data == 1)

        if (line =~ /Date=(.*$)/)
          date = $1
        end
        if (line =~ /StartTime=(\d+):(\d+):(\d+)\..*$/)
          start = $1 + $2 + $3
        end
        if (line =~ /Monitor=(\d+$)/)
          parsed_data["device"] = $1
        end
        if (line =~ /\[HRData\]/)
          hr_data = 1
        end
        if (line =~/Length=(\d+):(\d+):(.*$)/)
          duration = Float($1) * 3600
          duration += Float($2) * 60
          duration += Float($3)
        end
      end
      start_time = date + start
      parsed_data = { "start_time" => start_time, "datapoints" => datapoints, "duration" => duration }
    end
    
    # Take's an array of objects, and averages one field.
    def pick_array_field(data, field)
      data.map { |x| x[field] }
    end
end
