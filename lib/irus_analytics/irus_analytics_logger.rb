# frozen_string_literal: true

require "active_support/json"
require 'logger'

module IrusAnalytics

  class IrusAnalyticsLogger < Logger

    def format_message( _severity, _timestamp, _progname, msg )
      "#{msg}\n"
    end

  end

  def self.send_logger
    @@send_logger ||= send_logger_init
  end

  private
  def self.send_logger_init
    if defined? Rails
      logfile = Rails.root.join( 'log', "irus_analytics_#{Rails.env}.log" )
    else
      logfile = './log/irus_analytics_no_rails.log'
    end
    unless Dir.exist? File.dirname(logfile)
      Dir.mkdir File.dirname(logfile)
    end
    logfile = File.open( logfile, 'a' )
    logfile.sync = true # automatically flushes data to file
    IrusAnalyticsLogger.new( logfile )
  end
  public

  module DebugLogger

    def self.debug_logger
      @@debug_logger ||= if defined? Rails
                           Rails.logger
                         else
                           Logger.new(STDOUT)
                         end
    end

    def self.bold_debug( msg = nil, label: nil, lines: 1, &block )
      lines = 1 unless lines.positive?
      lines.times { debug_logger.debug ">>>>>>>>>>" }
      debug_logger.debug label if label.present?
      if msg.respond_to?( :each )
        msg.each { |m| debug_logger.debug m }
        debug_logger.debug nil, &block if block_given?
      else
        debug_logger.debug msg, &block
      end
      lines.times { debug_logger.debug ">>>>>>>>>>" }
    end

    def self.called_from
      "called from: #{caller_locations(1, 2)[1]}"
    end

    def self.caller
      "#{caller_locations(1, 2)[1]}"
    end

    def self.here
      "#{caller_locations(1, 1)[0]}"
    end

    def self.verbose_debug
      ::IrusAnalytics::Configuration.verbose_debug
    end

    def bold_debug( msg = nil, label: nil, lines: 1, &block )
      DebugLogger.bold_debug( msg, label: label, lines: lines, &block )
    end

    def called_from
      "called from: #{caller_locations(1, 2)[1]}"
    end

    def caller
      "#{caller_locations(1, 2)[1]}"
    end

    def here
      "#{caller_locations(1, 1)[0]}"
    end

    def verbose_debug
      ::IrusAnalytics::Configuration.verbose_debug
    end

  end

end
