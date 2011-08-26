require 'rake'

Dir["#{File.dirname(__FILE__)}/*.rake"].sort.each { |ext| load ext }