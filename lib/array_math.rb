module ArrayMath

  def average_array
    self.array_sum / self.size
  end

  def array_sum
    inject(0){ |sum,item| sum + item }
  end
end

class Array
  include ArrayMath
end