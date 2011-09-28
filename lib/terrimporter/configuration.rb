module TerrImporter
  class Application
    class Configuration < Hash

      attr_accessor :validations

      def initialize
      end

      #maybe deprecated... still need to check
      def mandatory_values_present?
        if self['export_path'].nil? or
            self['export_settings']['application'].nil? or
            self['application_url'].nil?
          false
        else
          true
        end
      end

      def application_url
        self['application_url']
      end

      def css_export_path
        self['css_export_path']
      end

      def js_export_path
        self['js_export_path']
      end

      def stylesheets_destination
        self['stylesheets']['destination_path']
      end

      def stylesheet_replace_strings
        self['stylesheets']['replace_strings']
      end

      def javascripts_destination
        self['javascripts']['destination_path']
      end

      def stylesheets
        stylesheet_list = ["base.css"]
        if has_stylesheets?
          stylesheet_list = stylesheet_list + self['stylesheets']['styles'].to_s.robust_split
        else
          LOG.debug "No additional stylesheets defined in configuration file."
        end
        stylesheet_list.add_missing_extension!('.css')
      end

      def images
        self['images']
      end

      def modules
        self['modules']
      end

      def images_server_path
        self['image_server_path']
      end

      def libraries_server_path
        self['libraries_server_path']
      end

      def dynamic_libraries
        libraries = self['javascripts']['dynamic_libraries'].robust_split
        libraries.add_missing_extension!('.js')
      end

      def replace_style_strings?
        !self['stylesheets'].nil? and
            !self['stylesheets']['replace_strings'].nil? and
            !self['stylesheets']['replace_strings'].first.nil?
      end

      def libraries_destination_path
        if !self['javascripts']['libraries_destination_path'].nil?
          File.join(self['javascripts']['libraries_destination_path'])
        else
          File.join(self['javascripts']['destination_path'])
        end
      end

      def export_settings
        self['export_settings']
      end

      def has_stylesheets?
        !self['stylesheets'].nil? and !self['stylesheets']['styles'].nil?
      end

      def has_dynamic_javascripts?
        !self['javascripts'].nil? and !self['javascripts']['dynamic_libraries'].nil?
      end

      def has_images?
        !self['images'].nil?
      end

      def has_modules?
        !self['modules'].nil?
      end

    end
  end
end