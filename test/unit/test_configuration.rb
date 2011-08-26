require "test_helper"


class ConfigurationTest < Test::Unit::TestCase
  include ConfigHelper

  def setup
    @configuration = TerrImporter::Application::Configuration.new test_config_file_path
    @configuration.load_configuration
  end

  def teardown
    puts "Cleaning up configuration files"
  end

  should 'find a configuration in the local path and not raise an error' do
    assert_nothing_raised do
      @configuration.determine_config_file_path
    end
  end

  context 'no configuration file around' do
    setup { @invalid_configuration = TerrImporter::Application::Configuration.new }

    should 'not find a configuration in the local path and raise an error' do
      assert_raise TerrImporter::ConfigurationError do
        @invalid_configuration.load_configuration
        @invalid_configuration
      end
    end
  end

  context 'invalid config file' do
    setup do
      @configuration = TerrImporter::Application::Configuration.new invalid_test_config_file_path
    end

    should 'throw an error on an invalid config file' do
      assert_raise TerrImporter::ConfigurationError do
        @configuration.load_configuration
      end
    end
  end

  context 'test config file independed functions' do
    setup {
      @configuration = TerrImporter::Application::Configuration.new
    }

    should 'get the current working directory as config file path' do
      config_in_cwd = File.join(Dir.pwd, config_default_name)
      assert_equal config_in_cwd, @configuration.determine_config_file_path
    end

    should 'create a config file in the current directory' do
      config_path = File.join(Dir.pwd, config_default_name)
      FileUtils.rm_f config_path if File.exists? config_path
      @configuration.create_config_file
      assert File.exists?(config_path)
    end
  end
end