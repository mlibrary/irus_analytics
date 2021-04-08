# frozen_string_literal: true

require "openurl"
require 'active_support/core_ext/module/delegation'

module IrusAnalytics

  class TrackerContextObjectBuilder
    attr_accessor :context_object
    delegate :admin, :referent, to: :context_object

    private
    def i18n_scope
      [:irus_analytics, :tracker_context]
    end

    def initialize
      @context_object = OpenURL::ContextObject.new
    end

    public
    %w(event_datestamp file_url http_referer ip_address item_oai_identifier source_repository usage_event_type user_agent).each do |name|
      define_method("set_#{name}") do | value |
        handle = IrusAnalytics.handles[name.to_sym]
        value = {'label' => I18n.t(".labels.#{name}", scope: i18n_scope), 'value' => value}
        admin.merge!(handle=>value)
      end
    end

    def set_client_ip_address(ip_address)
      set_ip_address("urn:ip:#{ip_address}")
    end

  end

end
