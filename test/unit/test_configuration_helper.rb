require "test_helper"


class ConfigValidatorTest < Test::Unit::TestCase
  include ConfigurationHelper

  def teardown
    FileUtils.remove(config_working_directory_path + '.bak') if File.exists? config_working_directory_path + '.bak'
    FileUtils.remove(config_working_directory_path) if File.exists? config_working_directory_path
  end

  should 'create a configuration file and backup the old one' do
    create_config_file
    backup_config_file
    assert File.exists?(config_working_directory_path + '.bak')
    assert_same false, File.exists?(config_working_directory_path)
  end

  should 'create a configuration file and remove the old one' do
    config_working_directory_path #todo whats this?
    create_config_file
    remove_config_file
    assert_same false, File.exists?(config_working_directory_path)
  end

  should 'create a configuration file' do
    create_config_file
    assert File.exists?(config_working_directory_path)
  end

  should 'create a configuration file and replace the application url' do
    application_url = "http://test.url"
    create_config_file(application_url)
    configuration = File.read(config_working_directory_path)
    assert configuration.include?("application_url: #{application_url}")
  end

end


