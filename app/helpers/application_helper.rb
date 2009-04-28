module ApplicationHelper
  def number_to_time(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end
  def number_to_short_time(seconds)
    twodigit_time = Time.at(seconds).utc.strftime("%H:%Mh")
    twodigit_time =~ /^0(.*$)/
    return $1
  end
end
