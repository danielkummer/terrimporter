require "test_helper"

class TestImporter < Test::Unit::TestCase
  def setup
    @importer = TerrImporter::Application::Importer.new({ :config_file => test_config_file_path })
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


  should 'replace a string in the stylesheet with the configured string' do
    line = "this line should replace the /img/ string with images"
    @importer.send(:stylesheet_replace_strings!, line)
    assert line.include? "/images/"
  end

  should 'replace a string in the stylesheet with the configured regex' do
    @importer.config['stylesheets']['replace'][0]['what'] = "r/re.+eg/"
    line = "this line should replace the regex string with images"
    @importer.send(:stylesheet_replace_strings!, line)
    assert line.include?("/images/"), "result not expected, is #{line}"
  end


end


=begin
methods to test

run_download

stylesheet_replace_strings!

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