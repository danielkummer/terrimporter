require "test_helper"

class TestImporter < Test::Unit::TestCase
  def setup
    create_tmp_test_directory
    @importer = TerrImporter::Application::Importer.new({:config_file => test_config_file_path})
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/base/0.5/public/css/base/base.css.php?appbaseurl=&application=/terrific/webapp/path&layout=project&debug=false&cache=false", :body => File.expand_path('test/fixtures/base.css'), :content_type => 'text/plain')
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/base/0.5/public/css/base/base.css.php?appbaseurl=&application=/terrific/webapp/path&layout=project&suffix=ie&debug=false&cache=false", :body => File.expand_path('test/fixtures/ie.css'), :content_type => 'text/plain')
    FakeWeb.register_uri(:get, "http://terrific.url/img", :body => File.expand_path('test/fixtures/img_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/", :body => File.expand_path('test/fixtures/img_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage1.png", :body => File.expand_path('test/fixtures/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage2.png", :body => File.expand_path('test/fixtures/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage3.png", :body => File.expand_path('test/fixtures/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds", :body => File.expand_path('test/fixtures/img_backgrounds_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds/", :body => File.expand_path('test/fixtures/img_backgrounds_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds/background.jpg", :body => File.expand_path('test/fixtures/background.jpg'), :content_type => 'image/jpg')
    FakeWeb.register_uri(:get, "http://terrific.url/js/libraries/dynamic/", :body => File.expand_path('test/fixtures/js_dyn_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/js/libraries/dynamic/dynlib.js", :body => File.expand_path('test/fixtures/dynlib.js'), :content_type => 'text/plain')
  end

  def teardown
    delete_tmp_test_directory
  end

  should 'be a dummy test for more tests to follow....' do
    assert true
  end

  context 'css string replacement' do


    should 'replace a string in the stylesheet with the configured string' do
      line = "this line should replace the /img/ string with images"
      @importer.send(:stylesheet_replace_strings!, line)
      assert line.include? "/images/"
    end

    should 'replace a string in the stylesheet with the configured regex' do
      @importer.config['stylesheets']['replace'][0]['what'] = "r/(re.+ex)/"
      line = "this line should replace the regex string with images"
      @importer.send(:stylesheet_replace_strings!, line)
      assert line.include?("/images/"), "result not expected, is #{line}"
    end
  end

  context 'file creation' do

    should 'create a directory if it doesn\'t exist' do
      directory = File.join(File.dirname(__FILE__), '..', 'tmp', 'test_mkdir')
      @importer.send(:check_and_create_dir, directory)
      assert File.directory? directory
      #cleanup
      FileUtils.rmdir directory
    end

    should 'not create a directory if it doesnt exist and create isnt used' do
      directory = File.join(File.dirname(__FILE__), '..', 'tmp', 'test_mkdir')
      @importer.send(:check_and_create_dir, directory, false)
      assert_equal false, File.directory?(directory)
    end

  end

  context 'css and js export path construction' do
    should 'raise an error on wrongly supplied arguments' do
      assert_raise TerrImporter::DefaultError do
        @importer.send(:construct_export_path, :invalid)
      end
    end

    should 'construct a valid js path for the base.js file' do
      path = @importer.send(:construct_export_path, :js)
      assert path.include? 'base.js'
    end

    should 'construct a valid js path for the base.js file and merge supplied options' do
      path = @importer.send(:construct_export_path, :js, {:additional => 'option'})
      assert path.include? 'additional=option'
    end

    should 'construct a valid js path for the base.css file' do
      path = @importer.send(:construct_export_path, :css)
      assert path.include? 'base.css'
      assert path.include? 'appbaseurl='
    end
  end

  context 'file lists' do
    should 'get a list of files from a directory html page' do
      files = @importer.send(:html_directory_content_list, '/img')
      assert files.size == 3
      assert files.include?("testimage1.png")
      assert files.include?("testimage2.png")
      assert files.include?("testimage3.png")
      assert files[0] == ("testimage1.png")
    end

    should 'not return subdirectories if included in file list' do
      files = @importer.send(:html_directory_content_list, '/img')
      assert_same false, files.include?("backgrounds/")
    end
  end

  context 'batch download files' do
    should 'download all images into the target folder' do
      @importer.send(:batch_download, '/img', tmp_test_directory)
      assert exists_in_tmp? 'testimage1.png'
      assert exists_in_tmp? 'testimage2.png'
      assert exists_in_tmp? 'testimage3.png'
    end

    should 'download only files specified by file extension' do
      @importer.send(:batch_download, '/img/backgrounds', tmp_test_directory, "doesntexist")
      assert_same false, exists_in_tmp?('background.jpg')
    end

    should 'download only files specified by file multiple extension' do
      @importer.send(:batch_download, '/img/backgrounds', tmp_test_directory, "doesntexist jpg")
      assert exists_in_tmp? 'background.jpg'
    end

  end

  context 'test public grand import functions - everything is preconfigured' do
    should 'import all images' do
      @importer.import_images

      assert exists_in_tmp?('public/images/testimage1.png'), "testimage1 doesn't exist"
      assert exists_in_tmp?('public/images/testimage2.png'), "testimage2 doesn't exist"
      assert exists_in_tmp?('public/images/testimage3.png'), "testimage3 doesn't exist"
      assert exists_in_tmp?('public/images/backgrounds/background.jpg'), "background doesn't exist"
    end

  end

  def exists_in_tmp?(name)
    File.exists? File.join(tmp_test_directory, name)
  end

end