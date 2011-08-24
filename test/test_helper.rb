require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'fake_web'


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'terrimporter'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'terrimporter'

class Test::Unit::TestCase
  def test_config_file_path
    File.join(File.dirname(__FILE__), 'fixtures', 'test.config.yml')
  end


end
