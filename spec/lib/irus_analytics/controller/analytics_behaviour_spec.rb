require 'spec_helper'

class TestClass
  include IrusAnalytics::Controller::AnalyticsBehaviour
  attr_accessor :request, :item_identifier
end

describe IrusAnalytics::Controller::AnalyticsBehaviour do

  describe ".send_analytics" do
    before(:each) do
       @test_class = TestClass.new
       @test_class.request  = double("request", :remote_ip => "127.0.0.1", :user_agent => "Test user agent",  url: "http://localhost:3000/test", referer: "http://localhost:3000")
       @test_class.item_identifier = "test:123"
    end
    it "will call the send_irus_analytics method with the correct params..." do
       # We set the datetime stamp to ensure sync
       date_time = "2014-06-09T16:56:48Z"
       allow(@test_class).to receive(:datetime_stamp) .and_return(date_time)
       allow(@test_class).to receive(:source_repository_name) .and_return("hydra.hull.ac.uk")
       allow(@test_class).to receive(:irus_server_address) .and_return("irus-server-address.org")
       allow(@test_class).to receive(:rails_environment) .and_return("production")

       expect(@test_class).to receive(:send_irus_analytics).with(date_stamp:date_time , client_ip_address:"127.0.0.1", user_agent: "Test user agent", item_oai_identifier: "test:123", file_url: "http://localhost:3000/test", 
                                                                                http_referer:  "http://localhost:3000",  source_repository: "hydra.hull.ac.uk")

        @test_class.send_analytics       
    end

  end  
end
