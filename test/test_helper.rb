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
  def schema_file_path
    File.join(File.dirname(__FILE__), '..', 'config', schema_default_name)
  end

  def invalid_test_config_file_path
    File.join(File.dirname(__FILE__), 'fixtures', 'invalid.config.yml')
  end

  def test_config_file_path
    File.join(File.dirname(__FILE__), 'fixtures', 'test.config.yml')
  end

  def min_test_config_file_path
    File.join(File.dirname(__FILE__), 'fixtures', 'minimal.test.config.yml')
  end

  def tmp_test_directory
    File.join(File.dirname(__FILE__), 'tmp')
  end

  def create_tmp_test_directory
    FileUtils.mkdir tmp_test_directory unless File.exists? tmp_test_directory
  end

  def delete_tmp_test_directory
    FileUtils.rm_rf tmp_test_directory
  end



end
