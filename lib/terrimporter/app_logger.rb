class Logger
  attr_accessor :level

  NUMBER_TO_NAME_MAP  = {0=>'DEBUG',  1=>'INFO',  2=>'WARN',  3=>'ERROR', 4=>'FATAL', 5=>'UNKNOWN'}
  NUMBER_TO_COLOR_MAP = {0=>'0;37',   1=>'32',    2=>'33',    3=>'31',    4=>'31',    5=>'37'}

  # more infos: https://wiki.archlinux.org/index.php/Color_Bash_Prompt
  #\033[0m      Text reset
  #\033[0;37m   White
  #\033[032m    Green
  #\033[033m    Yellow
  #\033[031m    Red
  #\033[037m    White

  # %s => [datetime], %s => color, %-5s => severity, %s => message
  LOG_FORMAT = "\033[0;37m %s \033[0m[\033[%sm%-5s\033[0m]: %s \n"
  TIME_FORMAT = "%H:%M:%S"

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
    self.output (LOG_FORMAT % [format_datetime(Time.now),color, sevstring, message])
  end

  def format_datetime(time)
    time.strftime(TIME_FORMAT)
  end

  def output(value)
    puts value
  end
end

LOG = Logger.new
