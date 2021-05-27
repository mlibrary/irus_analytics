# frozen_string_literal: true

require_relative '../../../../lib/irus_analytics/rails/generator_service'

class IrusAnalytics::InjectControllerHooksGenerator < Rails::Generators::Base

  AFTER_ACTION_LABEL = 'IrusAnalytics after action'.freeze
  INCLUDE_IRUS_ANALYTICS_CODE = 'include IrusAnalytics::Controller::AnalyticsBehaviour'.freeze
  INCLUDE_IRUS_ANALYTICS_LABEL = 'include IrusAnalytics controller behavior'.freeze
  ITEM_IDENTIFIER_METHOD_NAME = 'item_identifier_for_irus_analytics'.freeze
  SKIP_SEND_IRUS_ANALYTICS_METHOD_NAME = 'skip_send_irus_analytics?'.freeze

  VALID_TYPES = [ 'investigation', 'request' ].freeze
  TYPE_TO_AFTER_ACTION_METHOD = { 'investigation' => 'send_irus_analytics_investigation',
                                  'request' => 'send_irus_analytics_request' }.freeze

  argument :options_str, type: :string, default: '{}',
           desc: I18n.t('irus_analytics.generators.inject_controller_hooks.argument.options_str.desc')

  desc I18n.t('irus_analytics.generators.inject_controller_hooks.desc')

  if defined? Rails
    source_root Rails.root
  else
    # puts "File.expand_path('../../../..', __FILE__)=#{File.expand_path('../../../..', __FILE__)}"
    source_root File.expand_path('../../../..', __FILE__)
  end

  def inject_controller_code_using_class_name
    say_status "info", "inject_controller_code_using_class_name", :blue
    say_status "info", "type=#{type}", :blue
    say_status "info", "after_action=#{after_action}", :blue
    say_status "info", "controller_class_name=#{controller_class_name}", :blue
    return if after_action.blank?
    return if controller_class_name.blank?
    file_path = ::File.join( "app/controllers","#{controller_class_name.underscore}.rb" )
    do_inject_controller_code( file_path, controller_class_name, after_action: after_action )
  end

  def inject_controller_code_using_file_name
    say_status "info", "inject_controller_code_using_file_name", :blue
    say_status "info", "type=#{type}", :blue
    say_status "info", "after_action=#{after_action}", :blue
    say_status "info", "controller_file_name=#{controller_file_name}", :blue
    return if after_action.blank?
    return if controller_file_name.blank?
    file_path = ::File.join( "app/controllers", controller_file_name )
    do_inject_controller_code( file_path, controller_file_name.camelize, after_action: after_action )
  end

  private

  def cli_options
    @cli_options ||= cli_options_init
  end

  def cli_options_init
    rv = helper.cli_options_init( options_str: options_str, debug_verbose: debug_verbose? )
    if rv['type'].blank?
      rv['type'] = 'request'
      rv[:type] = 'request'
    elsif !VALID_TYPES.include?( rv['type'] )
      rv['type'] = 'request'
      rv[:type] = 'request'
    end
    return rv
  end

  def helper
    @helper ||= GeneratorService.new( generator: self,
                                      generator_name: self.class.name,
                                      debug_verbose: debug_verbose?,
                                      cli_options: options_str )
  end

  def debug_verbose?
    @debug_verbose ||= true
  end

  [ :after_action, :controller_class_name, :controller_file_name, :debug_verbose, :test_mode, :type ].each do |name|
    self.define_method name do
      cli_options[name]
    end
  end

  def do_inject_controller_code(file_path, class_name, after_action:)
    say_status "info", "do_inject_controller_code(#{file_path},#{class_name},#{after_action})", :blue
    say_status "info", "File.exist? #{file_path}='#{File.exist? file_path}'", :blue
    if File.exist? file_path
      fp = file_path
      if test_mode
        file_path_copy = ::File.join( ::File.dirname(fp), ::File.basename(fp, ".*") + "_copy" + ::File.extname(fp)  )
        say_status "info", "file_path_copy='#{file_path_copy}'", :blue if debug_verbose?
        copy_file( file_path, file_path_copy )
        say_status "info", "File.exist? #{file_path_copy}='#{File.exist? file_path_copy}'", :blue
        target_path = file_path_copy
      else
        target_path = file_path
      end
      inject_irus_include_analytics_controller_behavior( target_path, class_name )
      inject_after_action( target_path, after_action )
      inject_public_declaration( target_path, after_action )
      inject_item_identifier_method( target_path )
      inject_skip_send_irus_analytics_method( target_path )
    end

  end

  def after_action_code( after_action )
    "after_action :#{TYPE_TO_AFTER_ACTION_METHOD[type]}, only: [:#{after_action}]"
  end

  def inject_after_action( target_path, after_action )
    code = after_action_code( after_action )
    label = AFTER_ACTION_LABEL
    return if helper.initial_check_including( target_path, code, label )
    begin # while for breaks
      break if helper.inject_code_after_comment( target_path, code, AFTER_ACTION_LABEL, label )
      break if helper.inject_code_after_last_line_matching( target_path, code, /^\s*after_action .+$/, label )
      break if helper.inject_code_after_comment( target_path, code, INCLUDE_IRUS_ANALYTICS_LABEL, label )
      break if helper.inject_code_after_first_line_including( target_path, code, INCLUDE_IRUS_ANALYTICS_CODE, label )
    end while false # for breaks
    helper.say_status_error_first_line_including( target_path, code, label )
  end

  def inject_irus_include_analytics_controller_behavior( target_path, class_name )
    code = INCLUDE_IRUS_ANALYTICS_CODE
    label = INCLUDE_IRUS_ANALYTICS_LABEL
    say_status "info", I18n.t('irus_analytics.generators.inject_controller_hooks.say.looking_for', code: code), :blue
    line = helper.first_line_including( target_path, code )
    # say_status "info", "Found helper.first_line_including line='#{line}'", :blue
    if line.present?
      say_status "info", I18n.t('irus_analytics.generators.inject_controller_hooks.say.found', code: code), :green
    else
      begin # while for breaks
        break if helper.inject_code_after_last_line_matching( target_path, code, /^\s*include .+$/, label )
        break if helper.inject_code_after_first_line_including( target_path, code, "class #{class_name} ", label )
        break if helper.inject_code_after_first_line_including( target_path, code, "class #{class_name.demodulize} ", label )
      end while false # for breaks
      helper.say_status_error_first_line_including( target_path, code, label )
    end
  end

  def item_identifier_method_code
    <<-EOS
    def #{ITEM_IDENTIFIER_METHOD_NAME}
      # return the OAI identifier
      # http://www.openarchives.org/OAI/2.0/guidelines-oai-identifier.htm
      CatalogController.blacklight_config.oai[:provider][:record_prefix] + ":" + params[:id]
    end
    EOS
  end

  def inject_item_identifier_method( target_path )
    code = "def #{ITEM_IDENTIFIER_METHOD_NAME}"
    label = ITEM_IDENTIFIER_METHOD_NAME
    return if helper.initial_check_including( target_path, code, label )
    begin # while for breaks
      full_code = item_identifier_method_code
      break if helper.inject_code_after_first_line_matching( target_path, full_code, public_declaration_re, label )
    end while false # for breaks
    helper.say_status_warning_first_line_including( target_path, code, label )
  end

  def inject_public_declaration( target_path, after_action )
    code = 'public'
    label = "'public' declaration"
    return if helper.initial_check_matching( target_path, public_declaration_re, label )
    begin # while for breaks
      break if helper.inject_code_after_comment( target_path, code, AFTER_ACTION_LABEL )
      break if helper.inject_code_after_first_line_including( target_path, code, after_action_code( after_action ) )
    end while false # for breaks
    helper.say_status_error_first_line_matching( target_path, public_declaration_re, label )
  end

  def skip_send_irus_analytics_method
    <<-EOS
    def #{SKIP_SEND_IRUS_ANALYTICS_METHOD_NAME}(usage_event_type)
      # return true to skip tracking, for example to skip curation_concerns.visibility == 'private'
      case usage_event_type
      when '#{IrusAnalytics::INVESTIGATION}'
        false
      when '#{IrusAnalytics::REQUEST}'
        false
      end
    end
    EOS
  end

  def inject_skip_send_irus_analytics_method( target_path )
    code = "def #{SKIP_SEND_IRUS_ANALYTICS_METHOD_NAME}"
    label = SKIP_SEND_IRUS_ANALYTICS_METHOD_NAME
    return if helper.initial_check_including( target_path, code, label )
    begin # while for breaks
      full_code = skip_send_irus_analytics_method
      break if helper.inject_code_after_comment( target_path, full_code, ITEM_IDENTIFIER_METHOD_NAME, label )
      break if helper.inject_code_after_first_line_matching( target_path, full_code, public_declaration_re, label )
    end while false # for breaks
    helper.say_status_warning_first_line_including( target_path, code, label )
  end

  def public_declaration_re
    @public_declaration_re ||= /^\s*public(\s*\#.*|\s+)?/
  end

  def public_declaration_re_m
    @public_declaration_re_m ||= /\n[ \t]*public([ \t]*\#[^\n]*|[ \t]+)?\n/m
  end

end
