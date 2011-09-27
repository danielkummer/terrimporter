class Array
  def add_missing_extension!(ending)
    self.collect! do |item|
      unless item =~ /#{ending}$/
        item + ending
      else
        item
      end
    end
  end
end