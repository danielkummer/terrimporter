require 'open-uri'
require 'uri'

module TerrImporter
  class Application
    class Downloader
      include DownloadHelper

      def initialize(base_uri)
        @base_uri = base_uri
        LOG.info "Downloader initialized to uri: #{base_uri}"
      end

      def download(remote_path, local_path=nil)
        absolute_uri = absolute_path(remote_path)
        begin
          if local_path.nil? #download to buffer
            LOG.info "Download #{absolute_uri} to buffer"
            data = StringIO.new
            absolute_uri.open { |io| data = io.read }
            data.to_s
          else
            create_dir_path File.dirname(local_path)
            LOG.info "Download #{absolute_uri} to local path #{local_path}"
            open(local_path, "wb") { |file|
              file.write(absolute_uri.open.read)
            }
          end
        rescue SocketError => e
          raise DefaultError, "Error opening url #{absolute_uri}: \n #{e.message}"
        end
      end


      def batch_download(remote_path, relative_dest_path, type_filter = "")
        source_path = absolute_path(remote_path)
        create_dir_path relative_dest_path

        LOG.info "Download multiple files from #{source_path} to #{relative_dest_path} #{"allowed extensions: " + type_filter unless type_filter.empty?}"

        files = html_directory_content_list(source_path)

        unless type_filter.empty?
          LOG.info "Apply type filter: #{type_filter}"
          files = files.find_all { |file| file =~ Regexp.new(".*" + type_filter.robust_split.join("|") + "$") }
        end

        LOG.info "Download #{files.size} files..."
        files.each do |file|
          relative_destination_path = File.join(relative_dest_path.to_s, file)
          self.download(File.join(source_path.to_s, file), relative_destination_path)
        end
      end

      private
      def html_directory_content_list(remote_path)
        LOG.info "Get html directory list"
        output = self.download(remote_path)
        files = []

        output.scan(/<a\shref=\"([^\"]+)\"/) do |res|
          files << res[0] if not res[0] =~ /^\?/ and not res[0] =~ /.*\/$/ and res[0].size > 1
        end
        LOG.info "Found #{files.size} files"
        files
      end

      def absolute_path(relative_path)
        URI.join(@base_uri, relative_path)
      end

    end
  end
end
