module ArrayMath

  def average_array
    return 0.0 if self.size == 0
    self.array_sum / self.size
  end

  def array_sum
    inject(0){ |sum,item| sum + item }
  end
end

class Array
  include ArrayMath
end