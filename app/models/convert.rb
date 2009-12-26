class Convert
  def self.meters_to_feet(meters)
    meters * 3.2808399
  end 
  
  def self.meters_to_miles(meters)
    meters_to_feet(meters) / 5280
  end
  
  def self.ms_to_mph(ms)
    meters_to_miles(ms) * 3600
  end
  
  def self.ms_to_kmh(ms)
    ms / 1000 * 3600
  end
end