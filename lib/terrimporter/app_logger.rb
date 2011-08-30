class Logger
  attr_accessor :level

  NUMBER_TO_NAME_MAP = {0=>'DEBUG', 1=>'INFO', 2=>'WARN', 3=>'ERROR', 4=>'FATAL', 5=>'UNKNOWN'}
  NUMBER_TO_COLOR_MAP = {0=>'0;37', 1=>'32', 2=>'33', 3=>'31', 4=>'31', 5=>'37'}
  #CUSTOM_FORMAT = "[%s] %5s: %s\n"
  LOG_FORMAT = "\033[0;37m[%s]\033[0m[\033[%sm %5s \033[0m]: %s \n"
  #"#{message =}" "\033[0;37m#{Time.now.to_s(:db)}\033[0m [\033[#{color}m" + sprintf("%-5s","#{sevstring}") + "\033[0m] #{message.strip} (pid:#{$$})\n" unless message[-1] == ?\n
  TIME_FORMAT = "%H:% M:%S"

  def initialize
    self.level = 0
  end

  def error(message)
    log(3, message)
  end

  def info(message)
    log(1, message)
  end

  def log(severity, message)
    return if self.level > severity
    sevstring = NUMBER_TO_NAME_MAP[severity]
    color = NUMBER_TO_COLOR_MAP[severity]
    self.output (LOG_FORMAT % [format_datetime(Time.new),color, sevstring, message])
    #"\033[0;37m#{Time.now.to_s(:db)}\033[0m [\033[#{color}m" + sprintf("%-5s","#{sevstring}") + "\033[0m] #{message.strip} (pid:#{$$})\n"
  end

  def format_datetime(time)
    time.strftime(TIME_FORMAT)
  end

  def output(value)
    puts value
  end
end

LOG = Logger.new
