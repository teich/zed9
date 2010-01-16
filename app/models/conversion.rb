class Conversion
  Imperial = {
    :speed => 2.23693629,
    :elevation => 3.2808399,
    :distance => 0.000621371192,
    :hr => 1,
    :duration => 1,
    :calories => 1
  }
  
  Metric = {
    :speed => 3.6,
    :elevation => 1,
    :distance => 0.001,
    :hr => 1,
    :duration => 1,
    :calories => 1
  }
  
  ImperialToMetric = {
    :speed => 0.44704,
    :elevation => 0.3048,
    :distance => 1609.344,
  }
  
  MetricToImperial = {
    :speed => 2.23693629,
    :elevation => 3.2808399,
    :distance => 0.000621371192
  }
  
  def self.ConvertToMetric(options)
    if ImperialToMetric[options[:field]]
      return options[:value].to_f * ImperialToMetric[options[:field]]
    else
      return options[:value]
    end
  end
  
  def self.ConvertToImperial(options)
    if MetricToImperial[options[:field]]
      return options[:value].to_f * MetricToImperial[options[:field]]
    else
      return options[:value]
    end
  end
  
  def self.LocalizeParams(fields, metric)
    return fields if metric
    localized = {}
    fields.each do |key, value|
      localized[key] = Conversion::ConvertToMetric(:value => value, :field => key.intern)
    end
    return localized
  end
end