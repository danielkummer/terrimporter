class Statistic
  attr_accessor :statistics, :times

  def initialize
    @header = ["---SUMMARY Date: #{Time.now.strftime("%d.%m.%Y %H:%M:%S")}" ]
    self.statistics = {}
  end

  def add_message(type, message)
    init_data(type)
    self.statistics[type][:message] = message
  end

  def add(type)
    init_data(type)
    self.statistics[type][:count] += 1
  end

  def init_data(type)
    self.statistics[type] = {:count => 0, :message => ""} if self.statistics[type].nil?
  end

  def print_summary
    @header.each do |h|
      puts h
    end
    self.statistics.each do |key, value|

      puts "* %3s : %s" % [value[:count], value[:message]] unless value[:count] == 0
    end
  end

end

STAT = Statistic.new
