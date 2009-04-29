module ApplicationHelper
  def number_to_time(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end
  def number_to_short_time(seconds)
    twodigit_time = Time.at(seconds).utc.strftime("%H:%Mh")
    twodigit_time =~ /^0(.*$)/
    return $1
  end
  def activity_timestamp(start_time)
    time = start_time.strftime("%I:%M%p")
    if (time =~ /^0(.*$)/)
      short_time = $1
    else
      short_time = time
    end
    start_time.strftime("%A, %B %d, %Y at #{short_time.downcase}")
  end
end
