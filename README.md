veyor
=====

[![Ruby](https://github.com/sckott/veyor/workflows/Ruby/badge.svg)](https://github.com/sckott/veyor/actions?query=workflow%3ARuby)
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
* `Veyor.project_add` - add a project
* `Veyor.project_delete` - delete a project
* `Veyor.project_history` - get project history
* `Veyor.project_deployments` - get project deployments
* `Veyor.project_settings` - get project settings
* `Veyor.build_start` - start a build
* `Veyor.build_delete` - delete a build
* `Veyor.build_cancel` - cancel a build
* `Veyor.build_artifacts` - get build artifacts
* `Veyor.build_log` - get build logs
* `Veyor.environments` - get environments
* `Veyor.environment_settings` - get environment settings

More to come in future `veyor` versions

## Changes

For changes see the [Changelog](https://github.com/sckott/veyor/blob/master/CHANGELOG.md)

## Setup

```ruby
Veyor.configuration do |config|
  config.account_name = "janedoe"
  config.account_token = "<your token>"
end
```

Store those in env var keys like

* `ENV['APPVEYOR_ACCOUNT_NAME']`
* `ENV['APPVEYOR_API_TOKEN']`

An API key is not used if not provided - we don't error when it's missing as we did before. Use `verbose=true` to see request headers sent.

## In Ruby

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

### Kill all queued builds

Sometimes all your builds are queued and you need to kill all of them

```ruby
x = Veyor.projects();
x.each do |z|
  nm = z['name']
  puts "working on " + nm
  if z["builds"].length > 0
    # each build
    z["builds"].each do |w|
      if w['status'] == "queued"
        Veyor.build_cancel(project: nm, version: w['version'])
      end
    end
  end
end
```

## On the CLI

List commands

```
veyor
```

```
Commands:
  veyor cancel [Name] --version=VERSION  # Cancel build of branch of most recent commit
  veyor deployments [Name]               # Get project deployments
  veyor help [COMMAND]                   # Describe available commands or one specific command
  veyor history [Name]                   # Get project history
  veyor project [Name]                   # List a project
  veyor projects                         # List projects
  veyor settings [Name]                  # List a project's settings
  veyor start [Name]                     # Start build of branch of most recent commit
```

List your projects

```
veyor projects
```

```
alm
analogsea
aspacer
bmc
bold
ccafs
... cutoff
```

Get back json - parse with [jq](https://stedolan.github.io/jq/)

```
veyor projects --json | jq .[].builds[].status
```

```
"cancelled"
"success"
"success"
"failed"
"success"
"success"
```

List metadata for single project

```
veyor project cowsay
```

```
project: cowsay
repository: sckott/cowsay
branch: master
build status: cancelled
build ID: 3906530
```

JSON

```
veyor project cowsay --json | jq .project
```

```json
{
  "projectId": 44589,
  "accountId": 13586,
  "accountName": "sckott",
  "builds": [],
  "name": "cowsay",
  "slug": "cowsay",
  "repositoryType": "gitHub",
  "repositoryScm": "git",
  "repositoryName": "sckott/cowsay",
  "repositoryBranch": "master",
  "isPrivate": false,
  "skipBranchesWithoutAppveyorYml": false,
  "enableSecu
...cutoff
```

## Contributing

Bug reports and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Code of Conduct](https://github.com/sckott/veyor/blob/master/CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
