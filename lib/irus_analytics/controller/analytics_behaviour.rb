# frozen_string_literal: true

require 'logger'
require 'resque'
require 'active_support/core_ext/module/delegation'
require 'irus_analytics/configuration'
require 'irus_analytics/irus_analytics_logger'

module IrusAnalytics
  module Controller
    module AnalyticsBehaviour
      include DebugLogger

      private

      delegate :enabled,
               :enable_send_investigations,
               :enable_send_requests,
               :enable_skip_send_method,
               :irus_server_address,
               :source_repository, to: ::IrusAnalytics::Configuration

      attr_writer :logger

      def logger
        # @logger ||= Logger.new(STDOUT)
        @logger ||= ::IrusAnalytics::DebugLogger.debug_logger
      end

      def i18n_scope
        [:irus_analytics, :analytics_behaviour]
      end

      def debugger_method
        "#{self.class.name}.send_irus_analytics"
      end

      def display_warning
        logger.warn(%Q(#{I18n.t('.exited', method: debugger_method, scope: i18n_scope)}: #{I18n.t('.no_request_object', scope: i18n_scope)}))
      end

      %w(remote_ip user_agent url referer).each do |name|
        define_method(name) do
          request.respond_to?(name) && request.send(name) || nil
        end
      end

      def identifier
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "@identifier=#{@identifier}",
                     "" ] if verbose_debug
        return @identifier if @identifier.present?
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "respond_to?(:item_identifier_for_irus_analytics)=#{respond_to?(:item_identifier_for_irus_analytics)}",
                     "" ] if verbose_debug
        return nil unless respond_to?(:item_identifier_for_irus_analytics)
        rv = item_identifier_for_irus_analytics
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "item_identifier_for_irus_analytics=#{rv}",
                     "" ] if verbose_debug
        rv
      end

      # Returns UTC iso8601 version of Datetime
      def datetime_stamp
        Time.now.utc.iso8601
      end

      def robot_user_agent?(user_agent)
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "user_agent=#{user_agent}",
                     "" ] if verbose_debug
        IrusAnalytics::UserAgentFilter.filter_user_agent?(user_agent)
      end

      def analytics_params
        {
          date_stamp: datetime_stamp,
          client_ip_address: remote_ip,
          user_agent: user_agent,
          item_oai_identifier: identifier,
          file_url: url,
          http_referer: referer,
          source_repository: source_repository
        }
      end

      def filter_request?(request)
        !request.respond_to?(:user_agent) || (request.headers['HTTP_RANGE'] || robot_user_agent?(request.user_agent))
      end

      def log_missing
        if Rails.env.development? || Rails.env.test?
          logger.debug(%Q(#{I18n.t('.params_extracted', method: debugger_method, params: analytics_params, scope: i18n_scope)}))
        else
          logger.error(%Q(#{I18n.t('.exited', method: debugger_method, scope: i18n_scope)}:#{I18n.t('.no_server_address', scope:i18n_scope)}))
        end
        true
      end

      def missing_server?
        rv = irus_server_address.nil? && log_missing
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "irus_server_address=#{irus_server_address}",
                     "return value=#{rv}",
                     "" ] if verbose_debug
        rv
      end

      def enqueue
        begin
          server = irus_server_address
          params = analytics_params
          bold_debug [ here, called_from,
                       "self.class.name=#{self.class.name}",
                       "irus_server_address=#{server}",
                       "analytics_params=#{params}",
                       "@identifier=#{@identifier}",
                       "@usage_event_type=#{@usage_event_type}",
                       "" ] if verbose_debug
          Resque.enqueue(IrusClient, server, params, @usage_event_type)
        rescue Exception => e
          logger.error(%Q(#{I18n.t('.error', method: debugger_method, scope: i18n_scope)}:#{I18n.t('.enquing_error', error: e, scope: i18n_scope)}))
        end
      end

      def skip_send?(usage_event_type)
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "enable_skip_send_method=#{enable_skip_send_method}",
                     "usage_event_type=#{usage_event_type}",
                     "" ] if verbose_debug
        return false unless enable_skip_send_method
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "respond_to?(:skip_send_irus_analytics?)=#{respond_to?(:skip_send_irus_analytics?)}",
                     "" ] if verbose_debug
        return false unless respond_to?(:skip_send_irus_analytics?)
        rv = skip_send_irus_analytics?(usage_event_type)
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "skip_send_irus_analytics?(#{usage_event_type})=#{rv}",
                     "" ] if verbose_debug
        rv
      end

      public


      def send_irus_analytics_investigation(identifier=nil)
        send_irus_analytics(identifier=identifier, INVESTIGATION)
      end

      def send_irus_analytics_request(identifier=nil)
        send_irus_analytics(identifier=identifier, REQUEST)
      end


      def send_irus_analytics(identifier=nil, usage_event_type=REQUEST)
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "identifier=#{identifier}",
                     "usage_event_type=#{usage_event_type}",
                     "enabled=#{enabled}",
                     "" ] if verbose_debug
        return unless enabled
        return if skip_send?(usage_event_type)
        @identifier = identifier
        @usage_event_type = usage_event_type
        (request && ( filter_request?(request) || missing_server? || enqueue )) || display_warning
      end

    end
  end
end
