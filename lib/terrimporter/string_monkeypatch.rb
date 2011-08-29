class String
  def robust_split
    case self
      when /,/
        self.split(/,/).collect(&:strip)
      when /\s/
        self.split(/\s/).collect(&:strip)
      else
        [self.strip]
    end
  end
end
