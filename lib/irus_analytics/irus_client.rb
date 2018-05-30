require 'active_support/core_ext/hash/keys'
module IrusAnalytics
  class IrusClient
    @queue = :irus_analytics

    class << self
      def perform(irus_server_address, analytics_params)
        IrusAnalytics::IrusAnalyticsService.new(irus_server_address).send_analytics(analytics_params.deep_symbolize_keys)
      end
    end
  end
end