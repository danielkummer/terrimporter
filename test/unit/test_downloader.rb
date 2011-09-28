require "test_helper"

class DownloaderTest < Test::Unit::TestCase
  def setup
    create_tmp_test_directory
    @base_uri = 'http://terrific.url'
    @downloader = TerrImporter::Application::Downloader.new @base_uri
    FakeWeb.register_uri(:get, "http://terrific.url/js/libraries/dynamic/dynlib.js", :body => File.expand_path('test/fixtures/js/dynlib.js'), :content_type => 'text/plain')
    FakeWeb.register_uri(:get, "http://terrific.url/img", :body => File.expand_path('test/fixtures/html/img_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/", :body => File.expand_path('test/fixtures/html/img_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img", :body => File.expand_path('test/fixtures/html/img_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/", :body => File.expand_path('test/fixtures/html/img_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage1.png", :body => File.expand_path('test/fixtures/img/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage2.png", :body => File.expand_path('test/fixtures/img/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/testimage3.png", :body => File.expand_path('test/fixtures/img/testimage.png'), :content_type => 'image/png')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds", :body => File.expand_path('test/fixtures/html/img_backgrounds_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds/", :body => File.expand_path('test/fixtures/html/img_backgrounds_dir.html'), :content_type => 'text/html')
    FakeWeb.register_uri(:get, "http://terrific.url/img/backgrounds/background.jpg", :body => File.expand_path('test/fixtures/img/background.jpg'), :content_type => 'image/jpg')
  end

  def teardown
    FileUtils.rm_f @target_dir if not @target_dir.nil? and File.exists? @target_dir
    delete_tmp_test_directory
  end

  should 'join relative and base paths to get fully valid uri' do
    absolute_path = @downloader.send :url, 'first/test'
    assert_equal absolute_path, URI.parse(@base_uri + '/first/test')

    absolute_path = @downloader.send :url, '/second/test'
    assert_equal absolute_path, URI.parse(@base_uri + '/second/test')

    absolute_path = @downloader.send :url, '/third/test/'
    assert_equal absolute_path, URI.parse(@base_uri + '/third/test/')

  end

  should 'download a remote path to string' do
    result = @downloader.download 'js/libraries/dynamic/dynlib.js'
    assert result.include?('This file represents a dynamic js library'), "result wrong, contains #{result.to_s}"
  end

  should 'download a remote uri to string' do
    result = @downloader.download_to_buffer URI('http://terrific.url/js/libraries/dynamic/dynlib.js')
    assert result.include?('This file represents a dynamic js library'), "result wrong, contains #{result.to_s}"
  end

  should 'download a file to the tmp folder' do
    @target_dir = File.expand_path('/tmp/dynlib.js')
    @downloader.download @base_uri + '/js/libraries/dynamic/dynlib.js', @target_dir
    assert File.exists?(@target_dir), "File doesn't exist #{@target_dir}"
  end

  should 'download a file to the tmp folder' do
    @target_dir = File.expand_path('/tmp/dynlib.js')
    @downloader.download_to_file URI(@base_uri + '/js/libraries/dynamic/dynlib.js'), @target_dir
    assert File.exists?(@target_dir), "File doesn't exist #{@target_dir}"
  end

  should 'raise DefaultError, raised by invalid url socket error' do
    assert_raises TerrImporter::DefaultError do
      @downloader = TerrImporter::Application::Downloader.new 'http://url.doesntex.ist'
      @downloader.download('')
    end
  end

  context 'batch download files' do
    should 'download all images into the target folder' do
      @downloader.batch_download '/img', tmp_test_directory
      assert exists_in_tmp? 'testimage1.png'
      assert exists_in_tmp? 'testimage2.png'
      assert exists_in_tmp? 'testimage3.png'
    end

    should 'download only files specified by file extension' do
      @downloader.batch_download '/img/backgrounds/', tmp_test_directory, "doesntexist"
      assert_same false, exists_in_tmp?('background.jpg')
    end

    should 'download only files specified by file multiple extension' do
      @downloader.batch_download '/img/backgrounds/', tmp_test_directory, "doesntexist jpg"
      assert exists_in_tmp? 'background.jpg'
    end
  end

  context 'file lists' do
    should 'get a list of files from a directory html page' do
      files = @downloader.send(:html_directory_list, '/img')
      assert files.size == 3
      assert files.include?("testimage1.png")
      assert files.include?("testimage2.png")
      assert files.include?("testimage3.png")
      assert files[0] == ("testimage1.png")
    end

    should 'not return subdirectories if included in file list' do
      files = @downloader.send(:html_directory_list, '/img')
      assert_same false, files.include?("backgrounds/")
    end
  end

  context 'file creation' do

    should 'create a directory if it doesn\'t exist' do
      directory = File.join(File.dirname(__FILE__), '..', 'tmp', 'test_mkdir')
      created_or_exists = @downloader.create_directory directory
      assert File.directory? directory
      assert created_or_exists
      #cleanup
      FileUtils.rmdir directory
    end

    should 'not create a directory if it exists, but report that it exists' do
      directory = File.join(File.dirname(__FILE__), '..', 'tmp')
      created_or_exists= @downloader.create_directory directory
      assert created_or_exists
    end

  end
end