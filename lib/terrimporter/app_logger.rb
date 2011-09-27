class Logger
  include ApplicationHelper
  attr_accessor :level, :log_format

  LOG_LEVELS = {:debug => 0, :info => 1, :warn => 2, :error=> 3, :fatal => 4}
  LOG_COLORS = {:debug =>'33', :info =>'32', :warn =>'33', :error=>'31', :fatal =>'31'}

  # more infos: https://wiki.archlinux.org/index.php/Color_Bash_Prompt
  #\033[0m      Text reset
  #\033[0;37m   White
  #\033[032m    Green
  #\033[033m    Yellow
  #\033[031m    Red
  #\033[037m    White

  # %s => [datetime], %s => color, %-5s => severity, %s => message
  LOG_FORMAT_UNIX = "\033[0;37m %s \033[0m[\033[%sm%-5s\033[0m]: %s \n"
  LOG_FORMAT_WINDOWS = "%s %s[%-5s]: %s \n"
  TIME_FORMAT = "%H:%M:%S"

  def initialize
    self.level = :debug

    unless on_windows?
      self.log_format = LOG_FORMAT_UNIX
    else
      self.log_format = LOG_FORMAT_WINDOWS
    end
  end

  def error(message)
    log(:error, message)
  end

  def info(message)
    log(:info, message)
  end

  def debug(message)
    log(:debug, message)
  end

  def log(severity, message)
    return if LOG_LEVELS[severity] < LOG_LEVELS[self.level]

    color = ''
    unless on_windows?
      color = LOG_COLORS[severity]
    end

    if LOG_LEVELS[severity] >= LOG_LEVELS[:error]
      $stderr.puts(self.log_format % [format_datetime(Time.now), color, severity.to_s.upcase, message])
    else
      $stdout.puts(self.log_format % [format_datetime(Time.now), color, severity.to_s.upcase, message])
    end
  end

  def format_datetime(time)
    time.strftime(TIME_FORMAT)
  end

end

LOG = Logger.new
