class TerrImporter
  class Application
    class Options < Hash
      attr_reader :opts, :orig_args

      def initialize(args)
        super()

        @orig_args = args.clone

        self[:verbose] = true

        require 'optparse'
        @opts = OptionParser.new do |o|
          o.banner = 'Usage: #{File.basename($0)} [options] \n e.g. #{File.basename($0)} -a, use -i or --init for first time use'

          o.separator ''
          o.separator 'Common options:'

          o.on('-a', '--all', 'export everything configured; javascripts, css files and images') do
            self[:import_css] = true
            self[:import_js] = true
            self[:import_image] = true
          end

          o.on('-c', '--css', 'export configured css files') { self[:import_css] = true }
          o.on('-i', '--img', 'export configured image files') { self[:import_image] = true }
          o.on('-j', '--js', 'export configured javascript files') { self[:import_js] = true }
          o.on('--init', 'create configuration file in current working directory') { self[:init] = true }

          o.separator ''
          o.separator 'Additional configuration:'

          #o.on('-v', '--verbose [on, off], default [on]', [true, false], 'Verbose mode') do |v|
          o.on('-v', '--[no-]verbose', 'run verbosely') do |v|
            self[:verbose] = v
          end

          o.on('--version', 'Show version') do
            puts ::File.open(::File.join(File.dirname(__FILE__), "..", "VERSION"), 'r').gets
            exit
          end

          o.on_tail('-h', '--help', 'display this help and exit') { self[:show_help] = true }
        end

        begin
          @opts.parse!(args)
          self[:input_file] = args.shift
        rescue OptionParser::InvalidOption => e
          self[:invalid_argument] = e.message
        end
      end

      def merge(other)
        self.class.new(@orig_args + other.orig_args)
      end

    end
  end
end
