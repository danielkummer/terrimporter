require 'open-uri'
require 'uri'

module TerrImporter
  class Application
    class Downloader

      def initialize(base_uri)
        @base_uri = base_uri
        LOG.info "Downloader initialized to uri: #{base_uri}"
      end

      def download(remote_path, local_path=nil)
        absolute_uri = absolute_path(remote_path)
        begin
          if local_path.nil? #download to buffer
            data = StringIO.new

            LOG.info "Downloading #{absolute_uri} to buffer"

            absolute_uri.open { |io| data = io.read }
            data.to_s
          else
            LOG.info "Downloading #{absolute_uri} to local path #{local_path}"

            open(local_path, "wb") { |file|
              file.write(absolute_uri.open.read)
            }
          end
        rescue SocketError => e
          raise DefaultError, "Error opening url #{absolute_uri}: \n #{e.message}"
        end
      end

      private
      def absolute_path(relative_path)
        URI.join(@base_uri, relative_path)
      end
    end
  end
end
