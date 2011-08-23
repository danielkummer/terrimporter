require "helper"

class TestImporter < Test::Unit::TestCase
  def setup
    @importer = TerrImporter::Application::Importer.new
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/base/0.5/public/css/base/base.css.php?appbaseurl=&application=/terrific/webapp/path&layout=project&debug=false&cache=false", :body => File.expand_path('test/fixtures/base.css'), :content_type => 'text/plain')
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/base/0.5/public/css/base/base.css.php?appbaseurl=&application=/terrific/webapp/path&layout=project&suffix=ie&debug=false&cache=false", :body => File.expand_path('test/fixtures/ie.css'), :content_type => 'text/plain')
    FakeWeb.register_uri(:get, "http://terrific.url/img/", :body => File.expand_path('test/fixtures/img_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage1.png", :body => File.expand_path('test/fixtures/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage2.png", :body => File.expand_path('test/fixtures/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage3.png", :body => File.expand_path('test/fixtures/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds", :body => File.expand_path('test/fixtures/img_backgrounds_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds/background.jpg", :body => File.expand_path('test/fixtures/background.jpg'), :content_type => 'image/jpg')
    FakeWeb.register_uri(:get, "http://terrific.url/js/libraries/dynamic/", :body => File.expand_path('test/fixtures/js_dyn_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/js/libraries/dynamic/dynlib.js", :body => File.expand_path('test/fixtures/dynlib.js'), :content_type => 'text/plain')
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