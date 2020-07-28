# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'veyor/version'

Gem::Specification.new do |s|
  s.name        = 'veyor'
  s.version     = Veyor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0'
  s.date        = '2020-07-28'
  s.summary     = "Appveyor Ruby Client"
  s.description = "Low Level Ruby Client for the Appveyor API"
  s.authors     = "Scott Chamberlain"
  s.email       = 'myrmecocystus@gmail.com'
  s.homepage    = 'https://github.com/sckott/veyor'
  s.licenses    = 'MIT'

  s.files = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ["lib"]

  s.bindir      = 'bin'
  s.executables = ['veyor']

  s.add_development_dependency 'bundler', '~> 2.1', '>= 2.1.4'
  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.1'
  s.add_development_dependency 'test-unit', '~> 3.3', '>= 3.3.6'
  s.add_development_dependency 'simplecov', '~> 0.16.1'
  s.add_development_dependency 'codecov', '~> 0.1.14'

  s.add_runtime_dependency 'faraday', '~> 1.0', '>= 1.0.1'
  s.add_runtime_dependency 'faraday_middleware', '~> 1.0'
  s.add_runtime_dependency 'thor', '~> 1.0', '>= 1.0.1'
  s.add_runtime_dependency 'multi_json', '~> 1.15'
end
