# frozen_string_literal: true

module IrusAnalytics

  OPENURL_VERSION = 'Z39.88-2004'.freeze
  INVESTIGATION = 'Investigation'.freeze
  REQUEST = 'Request'.freeze

  # see: https://irus.jisc.ac.uk/r5/about/policies/tracker/
  @@handles = { event_datestamp:     "url_tim",
                file_url:            "svc_dat",
                http_referer:        "rfr_dat",
                ip_address:          "req_id",
                item_oai_identifier: "rft.artnum",
                openurl_version:     "url_ver",
                source_repository:   "rfr_id",
                usage_event_type:    "rft_dat",
                user_agent:          "req_dat" }.freeze

  def self.handles
    @@handles
  end

  @@usage_event_types = { investigation: INVESTIGATION, request: REQUEST }.freeze

  def self.usage_event_types
    @@usage_event_types
  end

end
