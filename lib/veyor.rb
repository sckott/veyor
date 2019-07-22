require "veyor/version"
require "veyor/request"
require 'veyor/utils'
require 'rexml/document'
require 'rexml/xpath'

# @!macro veyor_acct_proj
#   @param account [String] An Appveyor account name
#   @param project [String] An Appveyor project name

# @!macro veyor_verbose
#   @param verbose [Boolean] Print request headers to stdout. Default: false

# @!macro history_params
#   @param limit [Fixnum] Records per page
#   @param start_build [String] Build version to start at
#   @param branch [String] Branch name

# @!macro veyor_options
#   @param options [Hash] Hash of options for configuring the request, passed on to Faraday.new
#     - timeout [Fixnum] open/read timeout Integer in seconds
#     - open_timeout [Fixnum] read timeout Integer in seconds
#     - proxy [Hash] hash of proxy options
#       - uri [String] Proxy Server URI
#       - user [String] Proxy server username
#       - password [String] Proxy server password
#     - params_encoder [Hash] not sure what this is
#     - bind [Hash] A hash with host and port values
#     - boundary [String] of the boundary value
#     - oauth [Hash] A hash with OAuth details

##
# `Veyor` - The top level module for using methods
# to access veyor APIs
#
# The following methods are provided:
# * `Veyor.project` - get project by name, branch, or build version
# * `Veyor.projects` - get all projects
# * `Veyor.project_add` - add a project
# * `Veyor.project_delete` - delete a project
# * `Veyor.project_history` - get project history
# * `Veyor.project_deployments` - get project deployments
# * `Veyor.project_settings` - get project settings
# * `Veyor.build_start` - start a build
# * `Veyor.build_delete` - delete a build
# * `Veyor.build_cancel` - cancel a build
# * `Veyor.build_artifacts` - get build artifacts
# * `Veyor.build_log` - get build logs
# * `Veyor.environments` - get environments
# * `Veyor.environment_settings` - get environment settings
#
# More will be added in future `veyor` versions
#
# @see https://www.appveyor.com/docs/api/ for
# detailed description of the Appveyor API
#
# @see https://www.appveyor.com/docs/api/environments-deployments
# for documentation on the Environments API
#
# You no longer are required to have an API key for all 
# requests. If you're only doing GET requests against public projects 
# you won't need a key, but if you're doing GET requests against
# non-public projects, or non-GET requests against any projects then
# you'll need a key.


module Veyor
  extend Configuration

  define_setting :account_name, ENV['APPVEYOR_ACCOUNT_NAME']
  define_setting :account_token, ENV['APPVEYOR_API_TOKEN']
  define_setting :base_url, "https://ci.appveyor.com"

  ##
  # Fetch projects
  #
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      Veyor.projects
  def self.projects(options: nil, verbose: false)
    route = prep_route('projects', nil, nil, nil, nil)
    Request.new(route, {}, nil, options, verbose).get
  end

  ##
  # Get a single project - gets the latest build
  #
  # @!macro veyor_acct_proj
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @param branch [String] Branch name
  # @param version [String] Project version
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      # if account_name already set up
  #      Veyor.project(project: 'cowsay')
  #
  #      # if not, or to fetch a project not under your account
  #      Veyor.project(account: 'sckott', project: 'cowsay')
  #
  #      # get by branch
  #      Veyor.project(project: 'cowsay', branch: 'changeback')
  #
  #      # get by version
  #      Veyor.project(project: 'cowsay', version: '1.0.692')
  def self.project(account: nil, project: nil, branch: nil,
    version: nil, options: nil, verbose: false)

    route = prep_route('projects', get_account(account), project, branch, version)
    Request.new(route, {}, nil, options, verbose).get
  end

  ##
  # Add a project
  #
  # @param provider [String] provider name, one of gitHub, bitBucket, vso, 
  #   gitLab, kiln, stash, git, mercurial, subversion
  # @param slug [String] a project slug like e.g., foo/bar
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Hash] A hash
  #
  # @example
  #      require 'veyor'
  #      Veyor.project_add(provider: 'gitHub', slug: 'sckott/httpcode')
  def self.project_add(provider:, slug:, options: nil, verbose: false)
    route = prep_route('projects', nil, nil, nil, nil)
    body = { :repositoryProvider => check_provider(provider),
      :repositoryName => slug }
    Request.new(route, {}, body, options, verbose).post
  end

  ##
  # Delete a project
  #
  # @!macro veyor_acct_proj
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Int] 204 on success
  #
  # @example
  #      require 'veyor'
  #      Veyor.project_delete(account: 'sckott', project: 'httpcode')
  def self.project_delete(account:, project:, options: nil, verbose: false)
    route = prep_route('projects', account, project, nil, nil)
    Request.new(route, {}, nil, options, verbose).delete
  end

  ##
  # Get project history
  #
  # @!macro veyor_acct_proj
  # @!macro veyor_options
  # @!macro history_params
  # @!macro veyor_verbose
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      # get project history
  #      x = Veyor.project_history(project: 'cowsay');
  #      x['builds'].collect { |x| x['status'] }
  #
  #      # limit results
  #      Veyor.project_history(project: 'cowsay', limit: 3)
  #
  #      # start by a certain build version
  #      Veyor.project_history(project: 'cowsay', start_build: 2872582)
  #
  #      # get by branch
  #      Veyor.project_history(project: 'cowsay', branch: 'changeback')
  def self.project_history(account: nil, project: nil, limit: 10,
    start_build: nil, branch: nil, options: nil, verbose: false)

    route = sprintf('/projects/%s/%s/history', get_account(account), project)
    args = prep_args(limit, start_build, branch)
    Request.new(route, args, nil, options, verbose).get
  end

  ##
  # Get project deployments
  #
  # @!macro veyor_acct_proj
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      # get project deployments
  #      x = Veyor.project_deployments(project: 'cowsay');
  #      x['deployments']
  def self.project_deployments(account: nil, project: nil, options: nil, verbose: false)
    route = sprintf('/projects/%s/%s/deployments', get_account(account), project)
    Request.new(route, {}, nil, options, verbose).get
  end

  ##
  # Get project settings
  #
  # @!macro veyor_acct_proj
  # @param yaml [Boolean] Return yaml version of project settings. Default: false
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      # get project history
  #      x = Veyor.project_settings(project: 'cowsay')
  #      x['settings']
  #      x['settings']['configuration']
  #      # get yaml data
  #      x = Veyor.project_settings(project: 'cowsay', yaml: true)
  def self.project_settings(account: nil, project: nil, yaml: false, options: nil, verbose: false)
    route = sprintf('/projects/%s/%s/settings', get_account(account), project)
    if yaml
      route = route + '/yaml'
    end
    Request.new(route, {}, nil, options, verbose).get
  end

  ##
  # Start build of branch of most recent commit
  #
  # @!macro veyor_acct_proj
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @param branch [String] Branch name
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      # start a build
  #      x = Veyor.build_start(project: 'cowsay')
  def self.build_start(account: nil, project:, branch: 'master', options: nil, verbose: false)
    body = { :accountName => get_account(account),
      :projectSlug => project, :branch => branch }
    Request.new('builds', {}, body, options, verbose).post
  end

  ##
  # Cancel a build
  #
  # @!macro veyor_acct_proj
  # @param version [String] Project version
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Int] 204 on success
  #
  # @example
  #      require 'veyor'
  #      # start a build
  #      x = Veyor.build_start(project: 'cowsay')
  #      x = Veyor.build_cancel(project: 'cowsay', version: '1.0.6088')
  def self.build_cancel(account: nil, project:, version:, options: nil, verbose: false)
    route = sprintf('/builds/%s/%s/%s', get_account(account), project, version)
    Request.new(route, {}, nil, options, verbose).delete
  end

  ##
  # Delete a build
  #
  # @param build_id [String] Build ID
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Int] 204 on success
  #
  # @example
  #      require 'veyor'
  #      # start a build
  #      x = Veyor.build_start(project: 'cowsay')
  #      x = Veyor.build_delete(build_id: '17962865')
  def self.build_delete(build_id:, options: nil, verbose: false)
    route = sprintf('/builds/%s', build_id)
    Request.new(route, {}, nil, options, verbose).delete
  end

  ##
  # Download a build log
  #
  # @param job_id [String] Job ID
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      x = Veyor.build_log(job_id: '4b9u720e2sjulln9')
  def self.build_log(job_id:, options: nil, verbose: false)
    route = sprintf('/buildjobs/%s/log', job_id)
    Request.new(route, {}, nil, options, verbose).get
  end

  ##
  # List artifacts of a job
  #
  # @param job_id [String] Job ID
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      x = Veyor.build_artifacts(job_id: '4b9u720e2sjulln9')
  def self.build_artifacts(job_id:, options: nil, verbose: false)
    route = sprintf('/buildjobs/%s/artifacts', job_id)
    Request.new(route, {}, nil, options, verbose).get
  end

  # environments
  ##
  # Get environments
  #
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      x = Veyor.environments
  def self.environments(options: nil, verbose: false)
    Request.new('environments', {}, nil, options, verbose).get
  end

  # Get environment settings
  #
  # @param id [String] A deployment environment ID
  # @!macro veyor_options
  # @!macro veyor_verbose
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      Veyor.environment_settings(id: 123456)
  def self.environment_settings(id:, options: nil, verbose: false)
    route = sprintf('/environments/%s/settings', id)
    Request.new(route, {}, nil, options, verbose).get
  end  

end
