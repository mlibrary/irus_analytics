module IrusAnalytics
  class IrusClient
    @queue = :irus_analytics

    def self.perform(irus_server_address, analytics_params)
      service = IrusAnalytics::IrusAnalyticsService.new(irus_server_address)
      service.send_analytics(symbolize_keys(analytics_params))     
    end

    def self.symbolize_keys(hash)
      new={}
      hash.map do |key,value|
          if value.is_a?(Hash)
            value = symbolize_keys(value) 
          end
          new[key.to_sym]=value
      end        
      return new
    end 

  end
end