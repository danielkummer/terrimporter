require 'open-uri'
require 'uri'

module TerrImporter
  class Application
    class Downloader

      def initialize(base_uri)
        @base_uri = base_uri
        FakeWeb.register_uri(:get, "http://terrific.url", :body => File.expand_path('fixtures/base.css'), :content_type => 'text/plain')
      end

      def download(remote_path, local_path=nil)
        absolute_uri = absolute_path(remote_path)
        if local_path.nil? #download to return
          data = StringIO.new
          absolute_uri.open { |io| data = io.read }
          data.to_s
        else
          open(local_path, "wb") { |file|
            file.write(absolute_uri.open.read)
          }
        end
      end

      private
      def absolute_path(relative_path)
        URI.join(@base_uri, relative_path)
      end

    end
  end
end
