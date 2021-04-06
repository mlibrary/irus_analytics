require 'openurl'

module OpenURL

  # monkey / fix the lack of https
  # see: https://github.com/openurl/openurl/pull/5  -- Add rudimentary https:// support to OpenURL::Transport by mberkowski · Pull Request #5
  class TransportHttps < OpenURL::Transport
    def initialize(target_base_url, contextobject=nil, http_arguments={})
      super
      @client.use_ssl = true
    end
  end

end
