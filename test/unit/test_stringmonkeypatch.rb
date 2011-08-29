require "test_helper"

class TestStringMonkeypatch < Test::Unit::TestCase

  should 'split a string' do
    expected = ["this", "is", "a", "test"]

    assert_equal expected, expected.join(", ").robust_split
    assert_equal expected, expected.join(" ").robust_split
  end

end