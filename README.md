veyor
=====

[![Build Status](https://travis-ci.org/sckott/veyor.svg?branch=master)](https://travis-ci.org/sckott/veyor)
[![codecov.io](http://codecov.io/github/sckott/veyor/coverage.svg?branch=master)](http://codecov.io/github/sckott/veyor?branch=master)
[![gem version](https://img.shields.io/gem/v/veyor.svg)](https://rubygems.org/gems/veyor)

`veyor` is a low level client for the [Appveyor API](https://www.appveyor.com/docs/api)

API docs: <https://www.appveyor.com/docs/api>

## Installation

Stable version

```
gem install veyor
```

Development version

```
git clone https://github.com/sckott/veyor.git
cd veyor
rake install
```

## veyor API

* `Veyor.project` - get project by name, branch, or build version
* `Veyor.projects` - get all projects
* `Veyor.project_history` - get project history
* `Veyor.project_deployments` - get project deployments
* `Veyor.project_settings` - get project settings
* `Veyor.build_start` - start a build
* `Veyor.build_cancel` - cancel a build

More to come in future `veyor` versions

## Usage

```ruby
require 'veyor'
```

### setup

```ruby
Veyor.configuration do |config|
  config.account_name = "janedoe"
  config.account_token = "<your token>"
end
```

Or store those in env var keys like

* `ENV['APPVEYOR_ACCOUNT_NAME']`
* `ENV['APPVEYOR_API_TOKEN']`

### get projects

```ruby
Veyor.projects()
```

### get a project by name

```ruby
Veyor.project(project: 'cowsay')
```

### get project history

```ruby
Veyor.project_history(project: 'cowsay')
```

### start a build

```ruby
Veyor.build_start(project: 'cowsay')
```

### cancel a build

```ruby
Veyor.build_cancel(project: 'cowsay', version: '1.0.697')
```

## Contributing

Bug reports and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Code of Conduct][CONDUCT.md].


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
