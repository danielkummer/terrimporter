require "helper"

class TestImporter < Test::Unit::TestCase
  def setup
    create_test_configuration_file
    @importer = TerrImporter::Importer.new
    #todo mock load config with different path
  end

  def teardown
    delete_test_configuration_file
  end

=begin
  context 'configuration missing' do
    setup {}
    teardown {}

    should 'raise an error on missing configuration' do
      assert_raise TerrImporter::ConfigurationError do
        TerrImporter::Importer.new
        puts "raised"
      end
    end
  end
=end

  context 'configuration loading' do
    should 'get the current working directory as config file path' do
      config_in_cwd = File.join(Dir.pwd, TerrImporter::CONFIG_DEFAULT_NAME)
      assert_equal config_in_cwd, @importer.send(:config_file_path)
    end

    should 'get a configured directory path with the configuration file included' do
      assert_equal @test_configuration_file, @importer.send(:config_file_path, @tmp_dir_path)
    end

    should 'throw an exception on non existing config' do
      assert_raise TerrImporter::ConfigurationError do
        @importer.send(:init_config, File.join('does/not/exist'))
      end
    end
  end

  context 'configuration validation' do
    setup do
      @valid_config = YAML.load_file(@test_configuration_file)['terrific']
    end

    should 'see the copied original configuration as valid' do
      assert_nothing_raised do
        @importer.send(:validate_config, @valid_config)
      end
    end

    should 'get a configuration error if trying to do something unsupported' do
      invalid_bits = {
          'downloader' => 'something',
          'url' => 'invalidurl', #todo invalid url check not sane!!!!
          'version' => '',
          'app_path' => '',
          'export_path' => '',
          'image_base_path' => '',
          'stylesheets' => {'styles' => ['should_t_have_css_ext.css']},
          'javascripts' => {'dynamic_libraries' => ['should_t_have_js_ext.js'],
                            'libraries_dest' => ''
          }
      }

      invalid_bits.each do |k, v|
        assert_raise TerrImporter::ConfigurationError do
          puts "Testing invalid configuration: #{k} => #{v}"
          @importer.send(:validate_config, @valid_config.merge({k => v}))
        end
      end
    end
  end


  def create_test_configuration_file
    example_configuration_path = File.join(File.dirname(__FILE__), '..', '..', 'config', TerrImporter::CONFIG_DEFAULT_NAME)
    @tmp_dir_path = File.join(File.dirname(__FILE__), '..', 'tmp')
    @test_configuration_path = File.join(@tmp_dir_path, TerrImporter::CONFIG_DEFAULT_NAME)
    FileUtils.mkdir(@tmp_dir_path) unless File.exist? @tmp_dir_path
    FileUtils.cp example_configuration_path, @test_configuration_path
    @test_configuration_file = @test_configuration_path
  end

  def delete_test_configuration_file
    FileUtils.rm_rf @test_configuration_file if File.exists? @test_configuration_file
  end

end


=begin
methods to test

run_download

stylesheet_replace_strings

check_and_create_dir

construct_export_request

get_file_list

batch_download_files

init_config

config_file_path

load_config

validate_config

config_exists?


import_images

import_js

import_css

run

initialize

=end