require 'logger'
require 'resque'

module IrusAnalytics
  module Controller
    module AnalyticsBehaviour 
      def send_analytics
        logger = Logger.new(STDOUT) if logger.nil? 
        # Retrieve required params from the request
        if request.nil?
           logger.warn(
             %Q(
               #{I18n.t('irus_analytics.analytics_behaviour.exited', "#{self.class.name}.#{__method__}")}:
               #{I18n.t('irus_analytics.analytics_behaviour.no_request_object')}
             )
           )
        else
          # Should we filter this request...
          unless filter_request?(request)
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

            analytics_params = { date_stamp: datetime, client_ip_address: client_ip, user_agent: user_agent, item_oai_identifier: identifier, file_url: file_url, 
                                             http_referer: referer,  source_repository: source_repository }

            if irus_server_address.nil? 
              # In development and test Rails environment without irus_server_address we log in debug  
              if %w(development test).include?(Rails.env.to_s)
                logger.debug(
                  %Q(
                    #{I18n.t('irus_analytics.analytics_behaviour.params_extracted', "#{self.class.name}.#{__method__}", analytics_params)}
                  )
                )
              else
                logger.error(
                  %Q(
                    #{I18n.t('irus_analytics.analytics_behaviour.exited', "#{self.class.name}.#{__method__}")}:
                    #{I18n.t('irus_analytics.analytics_behaviour.no_server_address')}
                  )
                )
              end

            else
              begin
                Resque.enqueue(IrusClient, irus_server_address, analytics_params)
              rescue Exception => e
                logger.error("IrusAnalytics::Controller::AnalyticsBehaviour.send_analytics error: Problem enquing the analytics with Resque. Error: #{e}")
              end
            end
          end
        end
      end

      private


      # Returns UTC iso8601 version of Datetime
      def datetime_stamp
        Time.now.utc.iso8601
      end

      def source_repository_name
        IrusAnalytics::Configuration.source_repository
      end

      def irus_server_address
        IrusAnalytics::Configuration.irus_server_address
      end

      def filter_request?(request)
        filter_request = false 
        # If we can't determine the request.user_agent we should filter it...
        if request.respond_to?(:user_agent)
          filter_request = !request.headers['HTTP_RANGE'].nil?  || robot_user_agent?(request.user_agent) 
        else
          filter_request = true
        end
        filter_request
      end

      def robot_user_agent?(user_agent)
        IrusAnalytics::UserAgentFilter.filter_user_agent?(user_agent)
      end

      def rails_environment
        unless Rails.nil?
          return Rails.env.to_s 
        end
      end

    end
  end
end
