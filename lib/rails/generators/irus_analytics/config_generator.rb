module IrusAnalytics
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      desc 'Create custom IrusAnalytics configurations for repo applications'
      source_root File.expand_path('../../../../', __dir__)

      def copy_settings
        directory 'config'
      end
    end
  end
end
