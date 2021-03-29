# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'irus_analytics/version'

Gem::Specification.new do |spec|
  spec.name           = "irus_analytics"
  spec.version        = IrusAnalytics::VERSION
  spec.authors        = ["Simon Lamb"]
  spec.email           = ["s.lamb@hull.ac.uk"]
  spec.summary      = %q{IrusAnalytics is a gem that provides a simple way to send analytics to the IRUS-UK repository agggregation service. }
  spec.description   = %q{More information about IRUS-UK can be found at [http://www.irus.mimas.ac.uk/](http://www.irus.mimas.ac.uk/).  In summary the IRUS-UK service is designed to provide article-level usage statistics for Institutional Repositories. This gem was developed for use with a Hydra repository [http://projecthydra.org/(http://projecthydra.org/)], but it can be used with any other Rails based web application. }
  spec.homepage    = "https://github.com/uohull/irus_analytics"
  spec.license         = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "openurl", "~> 0.5"
  spec.add_dependency "resque", "~> 1.25"
  spec.add_dependency 'config_files', '~> 0.1.3'
  spec.add_dependency 'i18n', '~> 1.0'

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 0"
  spec.add_development_dependency "rspec", "~> 0"
end
