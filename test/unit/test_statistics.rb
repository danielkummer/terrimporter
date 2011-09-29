require 'test_helper'

class StatisticTest < Test::Unit::TestCase

  def setup
    @stat = Statistic.new
end

  should 'add an entry to the statistic' do
    @stat.add(:download, 1)
    assert @stat.statistics[:download][:count] == 1
  end

  should 'update an entry in the statistics' do
    @stat.add(:download, 1)
    @stat.add(:download, 1)
    assert @stat.statistics[:download][:count] == 2
  end

  should 'add a message to the statistic' do
    @stat.add_message(:download, "Downloads")
  end

  should 'output the header' do
    out = capture_stdout do
      @stat.print_summary
    end
    assert out.string.include? 'SUMMARY'
  end

  should 'output the messages added' do
    @stat.add_message(:download, "Downloads")
    @stat.add(:download, 1)
    @stat.add_message(:css, "CSS")
    @stat.add(:css, 1)

    out = capture_stdout do
      @stat.print_summary
    end
    assert out.string.include? 'Downloads'
    assert out.string.include? 'CSS'
  end

end