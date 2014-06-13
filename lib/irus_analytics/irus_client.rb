module IrusAnalytics
  class IrusClient
    @queue = :irus_analytics

    def self.perform(irus_server_address, analytics_params)
      service = IrusAnalytics::IrusAnalyticsService.new(irus_server_address)
      service.send_analytics(analytics_params)      
    end

  end
end