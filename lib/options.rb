class TerrImporter
  class Application
    class Options < Hash
      attr_reader :opts, :orig_args

      def initialize(args)
        super()

        @orig_args = args.clone

          #defaults
        self[:verbose] = true
        self[:import] = []

        require 'optparse'
        @opts = OptionParser.new do |o|
          o.banner = "Usage: #{File.basename($0)} [options] file.csv \n e.g. #{File.basename($0)} my_csv.csv"

          o.separator ""
          o.separator "Common options:"
          o.on('-a ', '--all', 'export everything configured; javascripts, css files and images') do
            self[:all] = true
          end

          o.on('-c ', '--css', 'export configured css files') do
            self[:import] << :css
          end

          o.on('-j ', '--js', 'export configured javascript files') do
            self[:import] << :js
          end

          o.on('-j ', '--img', 'export configured image files') do
            self[:import] << :image
          end




          o.separator ""
          o.separator "Additional configuration:"

          o.on('-v', '--verbose [on, off], default [on]', [true, false], 'Verbose mode') do |v|
            options[:verbose] = v
          end

          o.on("--version", "Show version") do
            puts OptionParser::Version.join('.')
            exit
          end

          o.on_tail('-h', '--help', 'display this help and exit') do
            self[:show_help] = true
          end
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
