require 'test_helper'

class LoggingTest < Test::Unit::TestCase
  include ApplicationHelper
  context 'test running environment' do
    setup do
      #todo set environment to emulate windows
    end

    should 'return true if ran on windows os' do
      assert_same false, on_windows?
    end
  end
end
