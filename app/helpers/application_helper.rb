module ApplicationHelper
  def number_to_time(seconds)
    Time.at(seconds).utc.strftime("%H:%M:%S")
  end
end
