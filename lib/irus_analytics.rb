require "resque/server"
require 'irus_analytics/elements'
require 'irus_analytics/irus_analytics_logger'
if defined?(Rails)
  require 'rails/generators'
  require 'irus_analytics/rail_tie'
end
require "irus_analytics/version"
require "irus_analytics/controller/analytics_behaviour"
require "irus_analytics/rails/generator_service"
require "irus_analytics/irus_analytics_service"
require "irus_analytics/tracker_context_object_builder"
require "irus_analytics/user_agent_filter"
require "irus_analytics/irus_client"
