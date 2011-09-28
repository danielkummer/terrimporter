#major todo!!
=begin
module TerrImporter
  class Application
    class StylesheetImporter
      include ImporterHelper
      attr_accessor :config

      def initialize(configuration)
        self.config = configuration
      end

      def import!
        LOG.info("Importing stylesheets")
        unclean_suffix = "_unclean"
        stylesheets = config.stylesheets

        stylesheets.each do |css|
          file_path = File.join(config.stylesheets_destination, css)
          options = {}
          options[:suffix] = $1 if css =~ /(ie.*).css$/ #add ie option if in array
          source_url = export_path(:css, options)
          unclean_file_path = file_path + unclean_suffix;
          constructed_file_path = (config.replace_style_strings? ? unclean_file_path : file_path)
          @downloader.download(source_url, constructed_file_path)

          if file_contains_valid_css?(constructed_file_path)
            if config.replace_style_strings?
              LOG.info "CSS line replacements"
              File.open(file_path, 'w') do |d|
                File.open(constructed_file_path, 'r') do |s|
                  lines = s.readlines
                  lines.each do |line|
                    d.print replace_stylesheet_lines!(line)
                  end
                end
              end
            else
              LOG.debug "Skipping css line replacements"
            end

            if File.exists?(unclean_file_path)
              LOG.debug "Deleting unclean css files"
              FileUtils.remove unclean_file_path
            end
          else
            File.remove(file_path)
            LOG.debug "Deleting empty"
          end
        end
      end

    end
  end
end
=end