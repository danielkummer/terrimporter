class Statistic
  attr_accessor :statistics, :times

  def header
    ["* SUMMARY Date: #{Time.now.strftime("%d.%m.%Y %H:%M:%S")}" ]
  end

  def initialize
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
    header.each { |h| puts h }
    self.statistics.each do |key, value|
      puts "%25s : %3s" % [value[:message], value[:count]] unless value[:count] == 0
    end
  end

end

STAT = Statistic.new
