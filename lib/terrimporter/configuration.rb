module TerrImporter
  class Application
    class Configuration < Hash

      def initialize(hash)
        hash.each do |key, value|
          self.instance_variable_set("@#{key}", value)
          self.class.send(:define_method, key, proc { self.instance_variable_get("@#{key}") })
          self.class.send(:define_method, "has_#{key}?", proc { !self.instance_variable_get("@#{key}").nil? and !self.instance_variable_get("@#{key}").empty? })
          self.class.send(:define_method, "#{key}=", proc { |value| self.instance_variable_set("@#{key}", value) })
          value.each_key do |key2|
            self.class.send(:define_method, "#{key}_#{key2}", proc { self.instance_variable_get("@#{key}")["#{key2}"] })
          end if value.kind_of? Hash
        end
      end

      def list_stylesheets
        stylesheet_list = ["base.css"]
        unless @stylesheets['styles'].nil?
          stylesheet_list = stylesheet_list + @stylesheets['styles'].to_s.robust_split
        else
          LOG.debug "No additional stylesheets defined in configuration file."
        end
        stylesheet_list.add_missing_extension!('.css')
      end

      def list_libraries
        libraries = @javascripts['libraries'].robust_split
        libraries.add_missing_extension!('.js')
      end

      def list_plugins
        libraries = @javascripts['plugins'].robust_split
        libraries.add_missing_extension!('.js')
      end

      def replace_style_strings?
        has_stylesheets? and
            !@stylesheets['replace'].nil? and
            !@stylesheets['replace'].first.nil?
      end

      def libraries_target_dir
        if !@javascripts['libraries_target_dir'].nil?
          File.join(@javascripts['libraries_target_dir'])
        else
          File.join(@javascripts['target_dir'])
        end
      end

      def plugins_target_dir
        if !@javascripts['plugins_target_dir'].nil?
          File.join(@javascripts['plugins_target_dir'])
        else
          File.join(@javascripts['target_dir'])
        end
      end


      def has_dynamic_javascripts?
        has_javascripts? and !@javascripts['libraries'].nil?
      end

      def has_plugins?
        has_javascripts? and !@javascripts['plugins'].nil?
      end
    end
  end
end