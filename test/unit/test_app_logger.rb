require 'test_helper'


class LoggingTest < Test::Unit::TestCase

  def setup
    @message = "This is a test message"
  end

  should 'log info to stdout' do
    LOG.info(@message)
    assert true
  end

  should 'log error to stdout' do
    LOG.error(@message)
    assert true
  end

end
