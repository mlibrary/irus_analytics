# frozen_string_literal: true

require 'active_support/core_ext/hash/keys'
require_relative './irus_analytics_logger'

module IrusAnalytics
  class IrusClient
    @queue = :irus_analytics

    class << self
      def perform(irus_server_address, analytics_params, usage_event_type)
        DebugLogger.bold_debug [ DebugLogger.here,
                                 DebugLogger.called_from,
                                 "irus_server_address=#{irus_server_address}",
                                 "analytics_params=#{analytics_params}",
                                 "usage_event_type=#{usage_event_type}",
                                 "" ] if DebugLogger.verbose_debug
        service = IrusAnalytics::IrusAnalyticsService.new(irus_server_address)
        case usage_event_type
        when REQUEST
          service.send_analytics_request(analytics_params.deep_symbolize_keys)
        when INVESTIGATION
          service.send_analytics_investigation(analytics_params.deep_symbolize_keys)
        else
          service.send_analytics(analytics_params.deep_symbolize_keys)
        end
      end
    end
  end
end
