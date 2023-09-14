require 'spec_helper'

describe IrusAnalytics::UserAgentFilter do
  context 'filter' do
    describe ".filter_user_agent" do
       it "will return true when a user agent should be filtered" do
         expect(IrusAnalytics::UserAgentFilter.filter_user_agent?("appie")).to be true
       end

       it "will return false when a user agent is valid and should not be filtered" do
        expect(IrusAnalytics::UserAgentFilter.filter_user_agent?("Firefox 3.0")).to be false
       end

       it "will return true with an empty user agent" do
        expect(IrusAnalytics::UserAgentFilter.filter_user_agent?("")).to be true
       end

       it "will return true with a nil user agent" do
        expect(IrusAnalytics::UserAgentFilter.filter_user_agent?(nil)).to be true
       end
    end
  end
end
