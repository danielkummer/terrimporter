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
          o.banner = "Usage: #{File.basename($0)} [options] \n" +
          "Use #{File.basename($0)} [application_url] --init to initialize importer before first usage."

          o.separator ''
          o.separator 'Common options:'

          o.on('-a', '--all', 'import everything configured; javascripts, css files and images') do
            self[:import_css] = true
            self[:import_js] = true
            self[:import_images] = true
          end

          o.on('-c', '--css', 'import configured css files') { self[:import_css] = true }

          o.on('-i', '--img', 'import configured image files') { self[:import_images] = true }

          o.on('-j', '--js', 'import configured javascript files') { self[:import_js] = true }

          o.on('-m', '--module', 'import configured module files') { self[:import_modules] = true }

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
            self[:show_version] = true
          end

          o.on_tail('-h', '--help', 'display this help and exit') { self[:show_help] = true }
        end

        begin
          @opts.parse!(args)
          self[:application_url] = args.shift
        rescue OptionParser::InvalidOption => e
          self[:invalid_option] = e.message
        rescue OptionParser::InvalidArgument => e
          self[:invalid_argument] = e.message
        end

      end

      def merge(other)
        self.class.new(@orig_args + other.orig_args)
      end
    end
  end
end
