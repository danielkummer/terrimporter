class Array
  def add_if_missing!(ending)
    self.collect! do |item|
      unless item =~ /#{ending}$/
        item + ending
      else
        item
      end
    end
  end
end