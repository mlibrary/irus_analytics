require "resque/server"
if defined?(Rails)
  require 'rails/generators'
  require 'irus_analytics/rail_tie'
end
require "irus_analytics/version"
require "irus_analytics/controller/analytics_behaviour"
require "irus_analytics/irus_analytics_service"
require "irus_analytics/tracker_context_object_builder"
require "irus_analytics/user_agent_filter"
require "irus_analytics/irus_client"

module IrusAnalytics
  class << self
    attr_writer :configuration 

    def configuration
      @configuration ||= IrusAnalytics::Configuration.new
    end

    def reset
      @configuration = nil
      configuration
    end

    def config
      yield(configuration)
    end
  end
end

