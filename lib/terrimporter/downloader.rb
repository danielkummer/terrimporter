require 'open-uri'
require 'uri'

module TerrImporter
  class Application
    class Downloader
      include DownloadHelper

      def initialize(base_uri)
        @base_uri = base_uri
        LOG.debug "Downloader initialized to uri: #{@base_uri}"
      end

      def download(remote_path, local_path = nil)
        remote_url = url(remote_path)
        begin
          if local_path.nil? #download to buffer
            LOG.debug "Download #{remote_url} to buffer"
            data = StringIO.new
            remote_url.open { |io| data = io.read }
            data.to_s
          else
            LOG.info "Download #{remote_url} to local path #{local_path}"
            create_dir_path File.dirname(local_path)
            open(local_path, "wb") { |file| file.write(remote_url.open.read) }
          end
        rescue SocketError => e
          raise DefaultError, "Error opening url #{remote_url}: \n #{e.message}"
        end
      end

      def batch_download(remote_path, local_path, type_filter = "")
        source_path = url(remote_path)
        create_dir_path local_path
        LOG.debug "Download multiple files from #{source_path} to #{local_path} #{"allowed extensions: " + type_filter unless type_filter.empty?}"

        files = html_directory_list(source_path)

        unless type_filter.empty?
          LOG.debug "Apply type filter: #{type_filter}"
          files = files.find_all { |file| file =~ Regexp.new(".*" + type_filter.robust_split.join("|") + "$") }
        end

        LOG.info "Download #{files.size} files..."
        files.each do |file|
          local_file_path = File.join(local_path.to_s, file)
          self.download(File.join(source_path.to_s, file), local_file_path)
        end
      end

      private
      def html_directory_list(remote_path)
        LOG.debug "Get html directory list"
        output = self.download(remote_path)
        files = []

        output.scan(/<a\shref=\"([^\"]+)\"/) do |res|
          files << res[0] if not res[0] =~ /^\?/ and not res[0] =~ /.*\/$/ and res[0].size > 1
        end
        LOG.debug "Found #{files.size} files"
        files
      end

      def url(relative_path)
        URI.join(@base_uri, relative_path)
      end
    end
  end
end
