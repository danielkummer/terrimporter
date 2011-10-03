require "test_helper"

class TestImporter < Test::Unit::TestCase
  def setup
    create_tmp_test_directory
    FakeWeb.register_uri(:get, "http://terrific.url", :body => File.expand_path('test/fixtures/html/application_root.html'), :content_type => 'text/plain')

    @importer = TerrImporter::Application::Importer.new({:config_file => test_config_file_path})
    FakeWeb.register_uri(:get, "http://terrific.url/", :body => File.expand_path('test/fixtures/html/application_root.html'), :content_type => 'text/plain')
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
    FakeWeb.register_uri(:get, "http://terrific.url/js/plugins/dynamic/dynplugin.js", :body => File.expand_path('test/fixtures/js/dynplugin.js'), :content_type => 'text/plain')
    FakeWeb.register_uri(:get, "http://terrific.url/js/libraries/dynamic/", :body => File.expand_path('test/fixtures/html/module.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/module/details/moduleName/moduleTemplate//format/modulecontent", :body => File.expand_path('test/fixtures/html/modulecontent.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/module/details/moduleName/moduleTemplate//format/module", :body => File.expand_path('test/fixtures/html/module.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/module/details/moduleName/moduleTemplate/moduleSkin/format/modulecontent", :body => File.expand_path('test/fixtures/html/modulecontent.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/terrific/module/details/moduleName/moduleTemplate/moduleSkin/format/module", :body => File.expand_path('test/fixtures/html/module.html'), :content_type => 'text/html')
  end

  def teardown
    delete_tmp_test_directory
  end


  context 'css string replacement' do
    should 'replace a string in the stylesheet with the configured string' do
      line = "this line should replace the /img/ string with images"
      @importer.send(:replace_stylesheet_lines!, line)
      assert line.include? "/images/"
    end

    should 'replace a string in the stylesheet with the configured regex' do
      @importer.config.stylesheets['replace_strings'][0]['what'] = "r/(re.+ex)/"
      line = "this line should replace the regex string with images"
      @importer.send(:replace_stylesheet_lines!, line)
      assert line.include?("/images/"), "result not expected, is #{line}"
    end

    #todo this tests is a fluke and not clean!
    should 'not do any string replacement if not configured' do
      @importer.config.stylesheets['replace_strings'] = nil
      @importer.import_css
      assert true
    end
  end

  context 'invalid css recognition' do
    should 'return false if an invalid css file is passed' do
      assert_equal false, @importer.file_contains_valid_css?(File.expand_path('test/fixtures/css/invalid.css'))
    end

    should 'return true if a valid css file is passed' do
      assert_equal true, @importer.file_contains_valid_css?(File.expand_path('test/fixtures/css/base.css'))
    end
  end

  context 'css and js export path construction' do
    setup do
      @importer.config.js_export_path = 'base.js'
      @importer.config.css_export_path = 'base.css'
    end

    should 'raise an error on wrongly supplied arguments' do
      assert_raise TerrImporter::DefaultError do
        @importer.send(:export_path, :invalid)
      end
    end

    should 'construct a valid js path for the base.js file' do
      path = @importer.send(:export_path, :js)
      assert path.include? 'base.js'
    end

    should 'construct a valid js path for the base.js file and merge supplied options' do
      path = @importer.send(:export_path, :js, {:additional => 'option'})
      assert path.include? 'additional=option'
    end

    should 'construct a valid js path for the base.css file' do
      path = @importer.send(:export_path, :css)
      assert path.include? 'base.css'
      assert path.include? 'appbaseurl='
    end
  end

  context 'test public grand import functions - everything is preconfigured' do
    should 'import all images' do
      @importer.import_images
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

    should 'import all module files' do
      @importer.import_modules
      assert exists_in_tmp?('modules/moduleName.html')
      assert exists_in_tmp?('modules/moduleName_moduleSkin.html')
    end

  end

  context 'execute run and check for correct resolve of commands' do
    setup do
      @importer.options[:import_js] = true
      @importer.options[:import_css] = true
      @importer.options[:import_images] = true
    end

    should 'import js, css and images, not using the :all statement' do
      @importer.run #only cherry-pick tests
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
      @importer.run
      #only cherry-pick tests
      assert exists_in_tmp?('public/images/testimage1.png')
      assert exists_in_tmp?('public/stylesheets/base.css')
      assert exists_in_tmp?('public/javascripts/base.js')
    end

  end

  context 'missing configuration values' do
    should 'run through but not throw an error if the servers library path is not specified' do
      @importer.config.libraries_server_path = nil
      assert_nothing_raised do
        @importer.import_js
      end
    end

    should 'run through but not throw an error if the images path is not specified' do
      @importer.config.images = nil
      assert_nothing_raised do
        @importer.import_images
      end
    end

    should 'run through but not throw an error if no modules are specified' do
      @importer.config.modules = nil
      assert_nothing_raised do
        @importer.import_modules
      end
    end

  end

  context 'module import' do
    #todo tests missing
  end

end