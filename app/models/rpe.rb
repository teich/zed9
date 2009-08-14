class RPE

  OPTIONS = [["", 0], ["No exertion at all", 6], ["Extremely light", 7], ["", 8], ["Very light", 9], ["", 10], ["Light", 11], ["Moderate", 12], ["Somewhat hard", 13], ["Hard", 14], ["", 15], ["Very hard", 16], ["", 17], ["Extremely hard", 18], ["", 19], ["Maximal exertion", 20]]

  def long_descriptions
    OPTIONS.map do |description, value|
      if value == 0
        ["", value]
      else
        seperator = description == "" ? "" : "-"
        ["#{value} #{seperator} #{description}", value]
      end
    end
  end

  def description(value)
    if value.nil? || value == 0
      return ""
    end
    desc = OPTIONS.rassoc(value)[0] 
    if desc == ""
      desc = OPTIONS.rassoc(value - 1)[0]  
    end
    return desc
  end

end
