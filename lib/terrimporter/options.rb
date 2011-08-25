module TerrImporter
  class Application
    class Options < Hash
      attr_reader :opts, :orig_args

      def initialize(args)
        super()

        @orig_args = args.clone

        self[:verbose] = true
        self[:show_help] = false

        require 'optparse'
        @opts = OptionParser.new do |o|
          o.banner = "Usage: #{File.basename($0)} [options] \n e.g. #{File.basename($0)} -a, use --init for first time use"

          o.separator ''
          o.separator 'Common options:'

          o.on('-a', '--all', 'export everything configured; javascripts, css files and images') do
            self[:import_css] = true
            self[:import_js] = true
            self[:import_images] = true
          end

          o.on('-c', '--css', 'export configured css files') { self[:import_css] = true }

          o.on('-i', '--img', 'export configured image files') { self[:import_images] = true }

          o.on('-j', '--js', 'export configured javascript files') { self[:import_js] = true }

          o.on('--init [CONFIG_EXISTS]', [:backup, :replace], 'create configuration file in current working directory. use optional argument to force file replacement (backup, replace)') do |init|
            self[:init] = init || true
          end

          o.on('-f', '--config CONFIG_FILE', 'use alternative configuration file') do |config_file|
            self[:config_file] = config_file
          end

          o.separator ''
          o.separator 'Additional configuration:'

          o.on('-v', '--[no-]verbose', 'run verbosely') do |v|
            self[:verbose] = v
          end

          o.on('--version', 'Show version') do
            puts TerrImporter::VERSION
            exit
          end

          o.on_tail('-h', '--help', 'display this help and exit') { self[:show_help] = true }
        end

        begin
          @opts.parse!(args)
          show_help_on_no_options
          self[:input_file] = args.shift
        rescue OptionParser::InvalidOption => e
          self[:invalid_argument] = e.message
        end
      end

      def merge(other)
        self.class.new(@orig_args + other.orig_args)
      end

      def show_help_on_no_options
        unless self[:import_css] or self[:import_js] or self[:import_images] or self[:init] or self[:version]
          puts "None of the default options selected, showing help"
          self[:show_help] = true
        else
          self[:show_help] = false
        end
      end
    end
  end
end
