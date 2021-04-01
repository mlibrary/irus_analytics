# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"

module IrusAnalytics

  module Integration

    @@_setup_ran = false
    @@_setup_failed = false

    mattr_accessor :enabled, default: true
    mattr_accessor :enable_send_logger, default: false
    mattr_accessor :verbose_debug, default: false

    def self.setup
      return if @@_setup_ran == true
      @@_setup_ran = true
      begin
        yield self
      rescue Exception => e # rubocop:disable Lint/RescueException
        @@_setup_failed = true
      end
    end

  end

end
