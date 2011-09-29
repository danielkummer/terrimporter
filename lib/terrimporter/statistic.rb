class Statistic
  attr_accessor :statistics, :times

  def initialize
    @header = ["-------------------------------",
               " SUMMARY ",
               "-------------------------------"]

    self.statistics = {
        :download => {:count => 0, :message => ""},
        :js => {:count => 0, :message => ""},
        :css => {:count => 0, :message => ""},
        :image => {:count => 0, :message => ""},
        :error => {:count => 0, :message => ""}
    }
  end

  def add_message(type, message)
    self.statistics[type][:message] = message
  end

  def add(type, count)
    self.statistics[type][:count] += count
  end

  def print_summary
    @header.each do |h|
      puts h
    end
    self.statistics.each do |key, value|
      puts "#{key.to_s.upcase}: [#{value[:count]}] #{value[:message]}" unless value[:count] == 0
    end
  end

end

STAT = Statistic.new
