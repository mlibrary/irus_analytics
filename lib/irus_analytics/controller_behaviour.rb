module IrusAnalytics
  module ControllerBehaviour
    def send_analytics
      # Retrieve required params from the request
      if request.nil?
         logger = Logger.new(STDOUT) if logger.nil? 
         logger.warn("send_analytics exited:Request object is nil.")
      else

        # Get Request data
        client_ip = request.remote_ip if request.respond_to?(:remote_ip)
        user_agent = request.user_agent if request.respond_to?(:user_agent)
        file_url = request.url if request.respond_to?(:url)
        referer = request.referer if request.respond_to?(:referer)
     
         # Defined locally
        datetime = datetime_stamp
        source_repository = source_repository_name

        # These following should defined in the controller class including this module
        identifier = self.item_identifier if self.respond_to?(:item_identifier)

        send_irus_analytics(date_stamp: datetime, client_ip_address:client_ip, user_agent: user_agent, item_oai_identifier: identifier, file_url: file_url, 
                                                                            http_referer: referer,  source_repository: source_repository)      
      end

    end

    private

    def send_irus_analytics(params)
        irus_analytics_service.send_analytics(params)
    end

    # Returns UTC iso8601 version of Datetime
    def datetime_stamp
      Time.now.utc.iso8601
    end

    def source_repository_name
      IrusAnalytics.configuration.source_repository
    end

    def irus_analytics_service
      IrusAnalytics::IrusAnalyticsService.new
    end

  end
end