# frozen_string_literal: true

require 'openurl'
require_relative './irus_analytics_logger'
require 'irus_analytics/elements'
require_relative '../openurl/transport_https'

module IrusAnalytics

  class IrusAnalyticsService
    include DebugLogger

    delegate :enabled,
             :enable_send_investigations,
             :enable_send_requests, to: ::IrusAnalytics::Configuration

    attr_accessor :irus_server_address,
                  :log_params,
                  :tracker_context_object_builder,
                  :transport_response_code

    def initialize(irus_server_address)
      bold_debug [ here, called_from,
                   "irus_server_address=#{irus_server_address}",
                   "" ] if verbose_debug
      @irus_server_address = irus_server_address
      @missing_params = []
    end

    def send_analytics_investigation(params = {})
      unless enable_send_investigations
        bold_debug [ here, called_from, "skipping investigate", "params=#{params}", "" ] if verbose_debug
        return
      end
      send_analytics(params, INVESTIGATION)
    end

    def send_analytics_request(params = {})
      unless enable_send_requests
        bold_debug [ here, called_from, "skipping request", "params=#{params}", "" ] if verbose_debug
        return
      end
      send_analytics(params, REQUEST)
    end

    def send_analytics(params = {}, usage_event_type=REQUEST)
      bold_debug [ here, called_from, "params=#{params}", "" ] if verbose_debug
      @log_params = params
      transport_reponse_code = nil
      if @irus_server_address.blank?
        raise ArgumentError, "Cannot send analytics: Missing Irus server address"
      end
      default_params = { date_stamp: "",
                         client_ip_address: "",
                         file_url: "",
                         http_referer: "",
                         item_oai_identifier: "",
                         source_repository: "",
                         usage_event_type: usage_event_type,
                         user_agent: "" }
      params = default_params.merge(params)
      @log_params = params

      if missing_mandatory_params?(params)
        raise ArgumentError, "Missing the following required params: #{@missing_params}"
      end

      @tracker_context_object_builder = IrusAnalytics::TrackerContextObjectBuilder.new

      @tracker_context_object_builder.set_event_datestamp(params[:date_stamp])
      @tracker_context_object_builder.set_client_ip_address(params[:client_ip_address])
      @tracker_context_object_builder.set_file_url(params[:file_url])
      @tracker_context_object_builder.set_http_referer(params[:http_referer])
      @tracker_context_object_builder.set_item_oai_identifier(params[:item_oai_identifier])
      @tracker_context_object_builder.set_source_repository(params[:source_repository])
      @tracker_context_object_builder.set_usage_event_type(params[:usage_event_type])
      @tracker_context_object_builder.set_user_agent(params[:user_agent])

      transport = openurl_link_resolver(@tracker_context_object_builder.context_object)
      transport.get

      @transport_reponse_code = transport.code

      if transport.code != "200"
        raise "Unexpected response from IRUS server"
      end

    ensure
      bold_debug [ here, called_from, "params=#{params}",
                   "::IrusAnalytics::Configuration.enable_send_logger=#{::IrusAnalytics::Configuration.enable_send_logger}",
                   "" ] if verbose_debug
      if ::IrusAnalytics::Configuration.enable_send_logger
        log_hash = {}
        log_hash[:params] = @log_params
        log_hash[:irus_server_address] = @irus_server_address
        log_hash[:missing_params] = @missing_params
        log_hash[:transport_repsonse_code] = @transport_reponse_code
        msg = ActiveSupport::JSON.encode( log_hash ).to_s
        IrusAnalytics.send_logger.info( msg )
      end
    end

    # At present, all the params, are mandatory...
    def missing_mandatory_params?(params)
      mandatory_params.each { |mandatory_param| @missing_params << mandatory_param  if params[mandatory_param].to_s.empty? }
      return !@missing_params.empty?
    end

    def mandatory_params
      [:date_stamp, :client_ip_address, :user_agent, :item_oai_identifier, :file_url, :source_repository]
    end

    def  openurl_link_resolver(context_object)
      OpenURL::TransportHttps.new(@irus_server_address, context_object)
    end

  end

end
