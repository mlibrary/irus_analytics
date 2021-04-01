# frozen_string_literal: true

require 'logger'
require 'resque'
require 'active_support/core_ext/module/delegation'
require 'irus_analytics/configuration'
require 'irus_analytics/integration'
require 'irus_analytics/irus_analytics_logger'

module IrusAnalytics
  module Controller
    module AnalyticsBehaviour
      include DebugLogger

      private

      delegate :source_repository, :irus_server_address, to: ::IrusAnalytics::Configuration
      attr_writer :logger

      def enable_irus_analytics?
        ::IrusAnalytics::Integration.enabled
      end

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
                     "respond_to?(:item_identifier)=#{respond_to?(:item_identifier)}",
                     "" ] if verbose_debug
        return nil unless respond_to?(:item_identifier)
        rv = item_identifier
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "item_identifier=#{rv}",
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
                       "" ] if verbose_debug
          Resque.enqueue(IrusClient, server, params)
        rescue Exception => e
          logger.error(%Q(#{I18n.t('.error', method: debugger_method, scope: i18n_scope)}:#{I18n.t('.enquing_error', error: e, scope: i18n_scope)}))
        end
      end

      public
      def send_irus_analytics(item_identifier=nil)
        bold_debug [ here, called_from,
                     "self.class.name=#{self.class.name}",
                     "item_identifier=#{item_identifier}",
                     "enable_irus_analytics?=#{enable_irus_analytics?}",
                     "" ] if verbose_debug
        return unless enable_irus_analytics?
        @identifier = item_identifier
        (request && ( filter_request?(request) || missing_server? || enqueue )) || display_warning
      end

    end
  end
end
