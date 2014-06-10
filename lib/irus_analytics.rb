require "irus_analytics/version"

module IrusAnalytics
   class << self
    attr_accessor :configuration 
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end    

  class Configuration
    attr_accessor :source_repository, :irus_server_address

    def initialize
      @source_repository = "locahost:3000"
      @irus_server_address = "localhost:3000/irus"
    end
  end

  def self.root
    @root ||= File.expand_path(File.dirname(File.dirname(__FILE__)))
  end

  def self.config
    File.join root, "config" 
  end 

end
