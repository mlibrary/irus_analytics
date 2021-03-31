# frozen_string_literal: true

class IrusAnalyticsGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  #check_class_collision suffix: "IrusAnalytics"

  def create_irus_analytics_config_initializer_file
    # Template method
    # First argument is the name of the template
    # Second argument is where to create the resulting file. In this case, app/components/my_component.rb
    # template "irus_analytics_config_init.rb", File.join("config/initializers",  "#{file_name}.rb")
    template "irus_analytics_config_init.rb", "config/initializers/irus_analytics.rb"
  end

  def copy_counter_robot_list
    copy_file "counter_robot_list.txt", "config/irus_analytics_counter_robot_list.txt"
  end

  def copy_irus_analytics_initializer
    template "irus_analytics_initializer.rb", "config/initializers/irus_analytics_initializer.rb"
  end

  private

  def default_enable_send_logger
    true
  end

  def default_irus_server_address
    "https://irus.jisc.ac.uk/counter/test/"
  end

  def default_source_repository( env )
    case env
    when "development"
      "localhost" # TODO
    when "test"
      "testing" # TODO
    else
      "production" # TODO
    end
  end

end
