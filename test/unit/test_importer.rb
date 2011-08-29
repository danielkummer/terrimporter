require "test_helper"

class TestImporter < Test::Unit::TestCase
  def setup
    create_tmp_test_directory
    @importer = TerrImporter::Application::Importer.new({:config_file => test_config_file_path})
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/base/0.5/public/css/base/base.css.php?appbaseurl=&application=/terrific/webapp/path&layout=project&debug=false&cache=false", :body => File.expand_path('test/fixtures/css/base.css'), :content_type => 'text/plain')
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/base/0.5/public/css/base/base.css.php?appbaseurl=&application=/terrific/webapp/path&layout=project&suffix=ie&debug=false&cache=false", :body => File.expand_path('test/fixtures/css/ie.css'), :content_type => 'text/plain')
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/base/0.5/public/js/base/base.js.php?layout=project&cache=false&application=/terrific/webapp/path&debug=false", :body => File.expand_path('test/fixtures/js/base.js'), :content_type => 'text/plain')
    FakeWeb.register_uri(:get, "http://terrific.url/img", :body => File.expand_path('test/fixtures/html/img_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/", :body => File.expand_path('test/fixtures/html/img_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage1.png", :body => File.expand_path('test/fixtures/img/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage2.png", :body => File.expand_path('test/fixtures/img/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage3.png", :body => File.expand_path('test/fixtures/img/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds", :body => File.expand_path('test/fixtures/html/img_backgrounds_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds/", :body => File.expand_path('test/fixtures/html/img_backgrounds_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds/background.jpg", :body => File.expand_path('test/fixtures/img/background.jpg'), :content_type => 'image/jpg')
    FakeWeb.register_uri(:get, "http://terrific.url/js/libraries/dynamic", :body => File.expand_path('test/fixtures/html/js_dyn_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/js/libraries/dynamic/", :body => File.expand_path('test/fixtures/html/js_dyn_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/js/libraries/dynamic/dynlib.js", :body => File.expand_path('test/fixtures/js/dynlib.js'), :content_type => 'text/plain')
  end

  def teardown
    delete_tmp_test_directory
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
      created_or_exists = @importer.send(:check_and_create_dir, directory)
      assert File.directory? directory
      assert created_or_exists
      #cleanup
      FileUtils.rmdir directory
    end

    should 'not create a directory if it doesnt exist and create isnt used' do
      directory = File.join(File.dirname(__FILE__), '..', 'tmp', 'test_mkdir')
      created_or_exists = @importer.send(:check_and_create_dir, directory, false)
      assert_equal false, File.directory?(directory)
      assert !created_or_exists
    end

    should 'not create a directory if it exists, but report that it exists' do
      directory = File.join(File.dirname(__FILE__), '..', 'tmp')
      created_or_exists= @importer.send(:check_and_create_dir, directory)
      assert created_or_exists
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
      @importer.send(:batch_download, '/img/backgrounds/', tmp_test_directory, "doesntexist")
      assert_same false, exists_in_tmp?('background.jpg')
    end

    should 'download only files specified by file multiple extension' do
      @importer.send(:batch_download, '/img/backgrounds/', tmp_test_directory, "doesntexist jpg")   #here broken
      assert exists_in_tmp? 'background.jpg'
    end

  end

  context 'test public grand import functions - everything is preconfigured' do
    should 'import all images' do
      @importer.import_images                            #here broken

      assert exists_in_tmp?('public/images/testimage1.png')
      assert exists_in_tmp?('public/images/testimage2.png')
      assert exists_in_tmp?('public/images/testimage3.png')
      assert exists_in_tmp?('public/images/backgrounds/background.jpg')
    end

    should 'import all css files' do
      @importer.import_css
      assert exists_in_tmp?('public/stylesheets/base.css')
      assert exists_in_tmp?('public/stylesheets/ie.css')
    end

    should 'import all js files' do
      @importer.import_js
      assert exists_in_tmp?('public/javascripts/base.js')
      assert exists_in_tmp?('public/javascripts/lib/dynlib.js')
    end

  end

  context 'execute run and check for correct resolve of commands' do
    setup do
      @importer.options[:import_js] = true
      @importer.options[:import_css] = true
      @importer.options[:import_images] = true
    end

    should 'import js, css and images, not using the :all statement' do
      @importer.run                                                        #here broken
      #only cherry-pick tests
      assert exists_in_tmp?('public/images/testimage1.png')
      assert exists_in_tmp?('public/stylesheets/base.css')
      assert exists_in_tmp?('public/javascripts/base.js')
    end
  end

  context 'execute run with all possible options enabled' do
    setup do
      @importer.options[:all] = true
    end
    should 'import js, css and images, using the :all statement' do
      @importer.run                                                           #here broken
      #only cherry-pick tests
      assert exists_in_tmp?('public/images/testimage1.png')
      assert exists_in_tmp?('public/stylesheets/base.css')
      assert exists_in_tmp?('public/javascripts/base.js')
    end

  end

  def exists_in_tmp?(name)
    File.exists? File.join(tmp_test_directory, name)
  end

end