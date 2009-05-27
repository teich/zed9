class Trackpoint
  attr_accessor :lat, :lng, :altitude, :speed, :heart_rate, :distance, :cadence, :time
  
	def initialize(opts = {:lat => nil, :lng => nil, :altitude => nil, :speed => nil, :heart_rate => nil, :distance => nil, :cadence => nil, :time => Time.now})
		@lat = opts[:lat]
		@lng = opts[:lng]
		@altitude = opts[:altitude]
		@speed = opts[:speed]
		@heart_rate = opts[:hr]
		@distance = opts[:distance]
		@time = opts[:time]
		@cadence = opts[:cadence]    
	end
end
