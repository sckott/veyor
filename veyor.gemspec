# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'veyor/version'

Gem::Specification.new do |s|
  s.name        = 'veyor'
  s.version     = Veyor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0'
  s.date        = '2016-06-24'
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

  s.add_development_dependency 'bundler', '~> 1.13', '>= 1.13.7'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'test-unit', '~> 3.2', '>= 3.2.3'
  s.add_development_dependency 'simplecov', '~> 0.12.0'
  s.add_development_dependency 'codecov', '~> 0.1.9'

  s.add_runtime_dependency 'faraday', '~> 0.10.1'
  s.add_runtime_dependency 'faraday_middleware', '~> 0.10.1'
  s.add_runtime_dependency 'thor', '~> 0.19.4'
  s.add_runtime_dependency 'multi_json', '~> 1.12', '>= 1.12.1'
end
