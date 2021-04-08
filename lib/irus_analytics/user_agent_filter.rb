require 'irus_analytics/configuration'

module IrusAnalytics
  class UserAgentFilter
    class << self
      def filter_user_agent?(user_agent)
        ::IrusAnalytics::Configuration.robots.any? {| robot_regex | user_agent.match(robot_regex)}
      end
    end
  end
end
