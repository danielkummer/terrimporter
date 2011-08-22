require "helper"

class TestImporter < Test::Unit::TestCase
  def setup
    @importer = TerrImporter::Importer.new
  end

  def teardown

  end

  should 'be a dummy test for more tests to follow....' do
    assert true
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