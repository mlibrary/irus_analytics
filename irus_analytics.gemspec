# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'irus_analytics/version'

Gem::Specification.new do |spec|
  spec.name        = "irus_analytics"
  spec.version     = IrusAnalytics::VERSION
  spec.authors     = ["Simon Lamb", "Fritz Freiheit"]
  spec.email       = ["s.lamb@hull.ac.uk"]
  spec.summary     = %q{IrusAnalytics is a gem that provides a simple way to send analytics to the IRUS-UK repository agggregation service. }
  spec.description = %q{More information about IRUS-UK can be found at [http://www.irus.mimas.ac.uk/](http://www.irus.mimas.ac.uk/).  In summary the IRUS-UK service is designed to provide article-level usage statistics for Institutional Repositories. This gem was developed for use with a Hydra repository [http://projecthydra.org/(http://projecthydra.org/)], but it can be used with any other Rails based web application. }
  spec.homepage    = "https://github.com/uohull/irus_analytics"
  spec.license     = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "openurl" # https://github.com/openurl/openurl
  spec.add_dependency "resque"
  spec.add_dependency 'config_files' # https://github.com/blackrat/config_files
  spec.add_dependency 'i18n'

  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
