# frozen_string_literal: true

class IrusAnalytics::ConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  # the following public methods are performed in order of appearance

  def copy_counter_robot_list
    copy_file 'counter_robot_list.txt', 'config/irus_analytics_counter_robot_list.txt'
  end

  def copy_irus_analytics_config
    template 'irus_analytics_config.yml', 'config/irus_analytics_config.yml'
  end

  def copy_irus_analytics_localization_en
    copy_file 'irus_analytics.en.yml', 'config/locales/irus_analytics.en.yml'
  end

  private

  def default_counter_robot_list
    'irus_analytics_counter_robot_list.txt'
  end

  def default_enable_send_logger
    true
  end

  def default_irus_server_address
    'https://irus.jisc.ac.uk/counter/test/'
  end

  def default_source_repository( env )
    case env
    when 'development'
      'localhost' # TODO
    when "test"
      'testing' # TODO
    else
      'production' # TODO
    end
  end

end
