require "helper"

class ImporterTest < Test::Unit::TestCase
  def setup
    create_test_configuration_file

  end




  should 'check for an existing config' do
    assert_nothing_raised TerrImporter::Importer.config_exists?(@config_file)
  end


  def create_test_configuration_file
    example_configuration_path = File.join(File.dirname(__FILE__), '..', '..', 'config', TerrImporter::CONFIG_DEFAULT_NAME)
    tmp_dir_path = File.join(File.dirname(__FILE__), '..', 'tmp')
    test_configuration_path = File.join(tmp_dir_path, TerrImporter::CONFIG_DEFAULT_NAME)
    FileUtils.mkdir(tmp_dir_path)
    FileUtils.cp example_configuration_path, test_configuration_path
    @test_configuration_file = test_configuration_path
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

validate_config

config_exists?


import_images

import_js

import_css

run

initialize

=end