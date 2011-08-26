require 'test_helper'


class LoggingTest < Test::Unit::TestCase
  include Logging

  def wrapped_log(message)
    original_stdout = $stdout
    original_stderr = $stderr

    fake_stdout = StringIO.new
    fake_stderr = StringIO.new

    $stdout = fake_stdout
    $stderr = fake_stderr

    begin
      log message
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end

    @stdout = fake_stdout.string
    @stderr = fake_stderr.string

  end

  context "supported logging operations" do
    should "log info to stdout" do
      wrapped_log :info => "hello world"
      assert @stdout.grep(/INFO.*hello world/)
    end

    should "log debug to stdout" do
      wrapped_log :debug => "hello world"
      assert @stdout.grep(/DEBUG.*hello world/)
    end

    should "log error to stdout" do
      wrapped_log :error => "hello world"
      assert @stdout.grep(/ERROR.*hello world/)
    end
  end

  should "not log anything unsupported" do
    wrapped_log :not_supported => "hello world"
    assert @stdout.strip.empty?
  end

end
