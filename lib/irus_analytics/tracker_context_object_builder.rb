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
    %w(event_datestamp ip_address user_agent file_url http_referer source_repository).each do |name|
      define_method("set_#{name}") do | value |
        admin.merge!(I18n.t(".handles.#{name}", scope: i18n_scope)=>{'label' => I18n.t(".labels.#{name}", scope: i18n_scope), 'value' => value})
      end
    end

    def set_client_ip_address(ip_address)
      set_ip_address("urn:ip:#{ip_address}")
    end

    def set_oai_identifier(identifier)
       referent.set_metadata("artnum", identifier)
    end
  end
end