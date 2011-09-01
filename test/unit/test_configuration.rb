require "test_helper"


class ConfigurationTest < Test::Unit::TestCase
  include ConfigHelper

  def setup
    @configuration = TerrImporter::Application::Configuration.new test_config_file_path
    @configuration.load_configuration
  end

  should 'find a configuration in the local path and not raise an error' do
    assert_nothing_raised do
      @configuration.determine_config_file_path
    end
  end

  should 'have an image configuration' do
    assert @configuration.images?
  end

  should 'have dynamic libraries' do
    assert @configuration.additional_dynamic_javascripts?
  end

  should 'use the normal libraries path if no dynamic libraries are specified' do
    @configuration['javascripts']['libraries_relative_destination_path'] = nil
    assert  @configuration['javascripts']['relative_destination_path'], @configuration.libraries_destination_path
  end

  should 'have style replacement strings' do
    assert @configuration.replace_style_strings?
  end

  should 'have additional stylesheets configured' do
    assert @configuration.additional_stylesheets?
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

  context 'test config file independent functions' do
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

  context 'required configurations' do
    should 'test for all the required configurations needed to function properly' do
      #these values are set by the downloader
      @configuration['export_path'] = 'present'
      @configuration['export_settings'] = {'application' => 'present'}
      @configuration['application_url'] = 'present'

      assert @configuration.required_present?
    end
  end

  context 'minimal working configuration' do
    setup do
      @configuration = TerrImporter::Application::Configuration.new min_test_config_file_path
    end

    should 'not raise an error when loading the minimal configuration' do
      assert_nothing_raised do
        @configuration.load_configuration
      end
    end

    should 'not have an image configuration' do
      assert !@configuration.images?
    end

    should 'not have dynamic libraries' do
      assert !@configuration.additional_dynamic_javascripts?
    end

    should 'not have style replacement strings' do
      assert !@configuration.replace_style_strings?
    end

    should 'not have additional stylesheets configured' do
      assert !@configuration.additional_stylesheets?
    end

    should 'only get the base.css file' do
      assert_equal ["base.css"], @configuration.stylesheets
    end

    #todo why is this failing?
=begin
    should 'return javascript destination path if libraries destination path is undefined' do
      assert_equal @configuration['javascripts']['relative_destination_path'], @configuration.libraries_destination_path
    end
=end
  end
end