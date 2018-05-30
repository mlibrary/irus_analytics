class IrusAnalyticsGenerator < Rails::Generators::Base
  desc 'Create custom IrusAnalytics configurations for repo applications'
  source_root File.expand_path('../../', __dir__)
  hook_for :irus_analytics, as: :install

  def copy_settings
    directory 'config'
  end
end
