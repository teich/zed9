class Activity < ActiveRecord::Base
  has_many :trackpoints
  
  def self.fetch_heart_rate
    foo = []
    self.trackpoints.each do |t|
      foo << t.heart_rate
    end
    return foo
  end
end
