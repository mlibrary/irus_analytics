class IrusAnalyticsGenerator < Rails::Generators::Base
  
  desc "Irus Analytics Generator"
  def create_irus_analytics_initializer
      initializer "irus_analytics.rb" do
<<EOF
  # Configuration of IrusAnalytics
  env = Rails.env.to_s

  IrusAnalytics.configuration.source_repository = case env
  when "development"
    "your-repository.org"
  when "test"
    "your-repository.org"
  else
    "your-repository.org"
  end

  IrusAnalytics.configuration.irus_server_address = case env
  when "development"
    nil
  when "test"
    nil
  else
    "irus_server_address"
  end
EOF

      end
  end
end