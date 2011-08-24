require "helper"



class DownloaderTest < Test::Unit::TestCase
 def setup
    @base_uri = 'http://terrific.url'
    @downloader = TerrImporter::Application::Downloader.new @base_uri
 end

 def teardown
   FileUtils.rm_f @target_dir if not @target_dir.nil? and File.exists? @target_dir
 end

  should 'join relative and base paths to get fully valid uri' do
    absolute_path = @downloader.send :absolute_path, 'first/test'
    assert_equal absolute_path, URI.parse(@base_uri + '/first/test')

    absolute_path = @downloader.send :absolute_path, '/second/test'
    assert_equal absolute_path, URI.parse(@base_uri + '/second/test')

    absolute_path = @downloader.send :absolute_path, '/third/test/'
    assert_equal absolute_path, URI.parse(@base_uri + '/third/test/')

  end

  should 'download a remote uri to string' do
    result = @downloader.download ''
    assert result.include? 'This is the base.css file'
  end

  should 'download a file to the tmp folder' do
    @target_dir = File.expand_path 'dynlib.js','tmp'
    @downloader.download @base_uri + '/js/libraries/dynamic/dynlib.js', @target_dir
    assert File.exists?(@target_dir), "File doesn't exist #{@target_dir}"
  end


end