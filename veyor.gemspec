# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'veyor/version'

Gem::Specification.new do |s|
  s.name        = 'veyor'
  s.version     = Veyor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0'
  s.date        = '2019-07-22'
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

  s.add_development_dependency 'bundler', '~> 2.0', '>= 2.0.1'
  s.add_development_dependency 'rake', '~> 12.3', '>= 12.3.2'
  s.add_development_dependency 'test-unit', '~> 3.3', '>= 3.3.3'
  s.add_development_dependency 'simplecov', '~> 0.16.1'
  s.add_development_dependency 'codecov', '~> 0.1.14'

  s.add_runtime_dependency 'faraday', '~> 0.15.4'
  s.add_runtime_dependency 'faraday_middleware', '~> 0.13.1'
  s.add_runtime_dependency 'thor', '~> 0.20.3'
  s.add_runtime_dependency 'multi_json', '~> 1.13', '>= 1.13.1'
end
