require "spec_helper"

describe IrusAnalytics::Configuration do

  describe "expected values in testing" do
    it { expect(::IrusAnalytics::Configuration.enabled).to eq true }
    it { expect(::IrusAnalytics::Configuration.enable_send_investigations).to eq true }
    it { expect(::IrusAnalytics::Configuration.enable_send_logger).to eq false }
    it { expect(::IrusAnalytics::Configuration.enable_send_requests).to eq true }
    it { expect(::IrusAnalytics::Configuration.enable_skip_send_method).to eq true }
    it { expect(::IrusAnalytics::Configuration.irus_server_address).to eq "<%= ENV['IRUS_SERVER_ADDRESS'] %>" }
    it { expect(::IrusAnalytics::Configuration.robots_file).to eq "irus_analytics_counter_robot_list.txt" }
    it { expect(::IrusAnalytics::Configuration.source_repository).to eq "your-repository.org" }
    it { expect(::IrusAnalytics::Configuration.verbose_debug).to eq false }

  end

end
