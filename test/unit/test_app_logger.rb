require 'test_helper'

class LoggingTest < Test::Unit::TestCase

  def setup
    @message = "This is a test message"
  end


  should 'log info to stdout' do
    out = capture_stdout do
      LOG.info(@message)
    end
    assert out.string.include? @message
    assert out.string.include? "INFO"
  end

  should 'log debug to stdout' do
    out = capture_stdout do
      LOG.debug(@message)
    end
    assert out.string.include? @message
    assert out.string.include? "DEBUG"
  end

  should 'log error to stdout' do
    out = capture_stderr do
      LOG.error(@message)
    end
    assert out.string.include? @message
    assert out.string.include? "ERROR"
  end

end
