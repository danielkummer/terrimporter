class TestArrayMonkeypatch < Test::Unit::TestCase

  should 'add an ending to each array object if it is missing' do

    testarray = ["file1.css", "file2", "file3", "file4.css"]
    expected = ["file1.css", "file2.css", "file3.css", "file4.css"]

    assert_equal expected, testarray.add_missing_extension!('.css')
    assert_equal expected, expected.join(" ").robust_split
  end

end