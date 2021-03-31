# frozen_string_literal: true

require 'config_files'
require 'configurations'

module IrusAnalytics
  class Configuration
    include ::ConfigFiles
    config_directories etc: [File.join(__dir__, '..', '..', 'config')]
    static_config_files :irus_config
    ::Configurations::MockRails.(self.directories[:etc]) if !defined?(Rails)

    class << self
      [:source_repository, :irus_server_address, :robots_file].each do |name|
        define_method name do
          irus_config[Rails.env][name.to_s]
        end
      end

      def robots
        ::Configurations::RobotsList.(::Configurations::SearchDirectoriesForFile.(self.directories[:etc], robots_file))
      end
    end
  end
end
