require "helper"



class DownloaderTest < Test::Unit::TestCase
 def setup
    @base_uri = 'http://terrific.url'
    @downloader = TerrImporter::Application::Downloader.new @base_uri
 end

 def teardown

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
    result = @downloader.download_to_output ''

    assert result.include? 'This is the base.css file'
  end


end