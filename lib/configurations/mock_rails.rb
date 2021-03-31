# frozen_string_literal: true

require 'i18n'
require 'active_support/string_inquirer'
require 'logger'

module Configurations
  class MockRails
    class << self
      def call(directories)
        I18n.load_path = directories.map{|dir| Dir[ ::File.join(dir.to_s, 'locales', '*.yml') ] }
        I18n.config.available_locales = :en
        I18n.backend.load_translations
        Object.const_set('Rails', Class.new do
          define_singleton_method(:env) do
            ::ActiveSupport::StringInquirer.new(ENV['RAILS_ENV'] || 'production')
          end
          @@logger = Logger.new( STDOUT )
          define_singleton_method(:logger)  { @@logger }
          define_singleton_method(:logger=) { |logger| @@logger=logger }
          define_singleton_method(:root)    { Pathname.new('.') }
        end) unless defined?(Rails)
      end
    end
  end
end
