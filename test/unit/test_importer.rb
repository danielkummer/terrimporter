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

  should 'check for an existing config' do
    assert_nothing_raised do
      @importer.send :config_exists?, @test_configuration_file
    end
  end


  def create_test_configuration_file
    example_configuration_path = File.join(File.dirname(__FILE__), '..', '..', 'config', TerrImporter::CONFIG_DEFAULT_NAME)
    tmp_dir_path = File.join(File.dirname(__FILE__), '..', 'tmp')
    test_configuration_path = File.join(tmp_dir_path, TerrImporter::CONFIG_DEFAULT_NAME)
    FileUtils.mkdir(tmp_dir_path) unless File.exist? tmp_dir_path
    FileUtils.cp example_configuration_path, test_configuration_path
    @test_configuration_file = test_configuration_path
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