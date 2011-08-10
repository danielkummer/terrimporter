module Logging
  require 'logger'

  #logformatter monkeypatch
  class LogFormatter < Logger::Formatter
    CUSTOM_FORMAT = "[%s] %5s %s: %s\n"

    def call(severity, time, progname, message)
      CUSTOM_FORMAT % [format_datetime(time), severity, progname, msg2str(message)]
    end

    def format_datetime(time)
      time.strftime("%Y-%m-%d %H:%M:%S")
    end
  end


# @param hash [:info => "message", :debug => "message", :error => "message"]
  def log(hash)
    Logging.log.debug hash[:debug] unless hash[:debug].nil?
    Logging.log.info hash[:info] unless hash[:info].nil?
    Logging.log.warn hash[:warn] unless hash[:warn].nil?
    Logging.log.error hash[:error] unless hash[:error].nil?
    Logging.log.fatal hash[:fatal] unless hash[:fatal].nil?
  end

  def self.log
    @logger ||= Logger.new $stdout
    @logger.formatter = LogFormatter.new
    @logger
  end

  def verbose?
    !self.options.nil? && self.options[:verbose] = true
  end

  def self.initialize_logger

  end

end


