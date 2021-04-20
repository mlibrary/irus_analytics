# frozen_string_literal: true

require 'config_files'
require 'configurations'

module IrusAnalytics
  class Configuration
    include ::ConfigFiles

    if defined? Rails
      # puts "\n>>\n>>\nFile.absolute_path(File.join('.', 'config'))=#{File.absolute_path(File.join('.', 'config'))}\n>>\n>>\n"
      # puts "\n>>\n>>\nRails.root=#{Rails.root}\n>>\n>>\n"
      config_dirs = [File.absolute_path(File.join('.', 'config'))]
    else
      config_dirs = [File.join(__dir__, '..', '..', 'config')]
    end
    config_directories etc: config_dirs

    static_config_files :irus_analytics_config
    ::Configurations::MockRails.(self.directories[:etc]) unless defined? Rails

    class << self
      [ :enabled,
        :enable_send_investigations,
        :enable_send_logger,
        :enable_send_requests,
        :enable_skip_send_method,
        :irus_server_address,
        :robots_file,
        :source_repository,
        :verbose_debug ].each do |name|

        define_method name do
          rv = nil
          if defined?( Settings ) && Settings.hostname.present?
            if irus_analytics_config[Rails.env][:named_servers].present?
              named_server = Settings.hostname
              rv = irus_analytics_config[Rails.env][named_server][name.to_s]
            end
          end
          rv = irus_analytics_config[Rails.env][name.to_s] if rv.blank?
          rv
        end
      end

      def robots
        ::Configurations::RobotsList.(::Configurations::SearchDirectoriesForFile.(self.directories[:etc], robots_file))
      end
    end
  end
end
