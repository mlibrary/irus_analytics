require 'openurl'
require 'ruby-debug'

module IrusAnalytics
  class IrusAnalyticsService
     attr_accessor :irus_server_address

     def initialize(irus_server_address)
      @irus_server_address = irus_server_address
      @missing_params = []
    end

     def send_analytics(params = {})
      if @irus_server_address.to_s.empty? 
        raise ArgumentError, "Cannot send analytics: Missing Irus server address"
      end

      default_params = {date_stamp: "", client_ip_address: "",  user_agent: "", item_oai_identifier: "", file_url: "", http_referer: "", source_repository: ""}
      params = default_params.merge(params)

      if missing_mandatory_params?(params)
        raise ArgumentError, "Missing the following required params: #{@missing_params}"
      end

      tracker_context_object_builder.set_event_datestamp(params[:date_stamp])
      tracker_context_object_builder.set_client_ip_address(params[:client_ip_address])
      tracker_context_object_builder.set_user_agent(params[:user_agent])
      tracker_context_object_builder.set_oai_identifier(params[:item_oai_identifier])
      tracker_context_object_builder.set_file_url(params[:file_url])
      tracker_context_object_builder.set_http_referer(params[:http_referer])
      tracker_context_object_builder.set_source_repository(params[:source_repository])

      transport = openurl_link_resolver(tracker_context_object_builder.context_object)
      transport.get 

      if transport.code != "200"
        raise "Unexpected response from IRUS server"
      end

     end

     # At present, all the params, are mandatory...
     def missing_mandatory_params?(params)
       params.each_pair { |key,value| @missing_fields << key if value.to_s.empty?  }
       return !@missing_params.empty? 
     end

     def tracker_context_object_builder
        IrusAnalytics::TrackerContextObjectBuilder.new
     end

     def  openurl_link_resolver(context_object)
       OpenURL::Transport.new(@irus_server_address, context_object)
     end

  end 
end
