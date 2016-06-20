require "veyor/version"
require "veyor/request"
require 'veyor/utils'
require 'rexml/document'
require 'rexml/xpath'

# @!macro veyor_params
#   @param offset [Fixnum] Number of record to start at, from 1 to infinity.
#   @param limit [Fixnum] Number of results to return. Not relavant when searching with specific dois. Default: 20. Max: 1000
#   @param sample [Fixnum] Number of random results to return. when you use the sample parameter,
#       the limit and offset parameters are ignored. This parameter only used when works requested.
#   @param sort [String] Field to sort on, one of score, relevance,
#       updated (date of most recent change to metadata - currently the same as deposited),
#       deposited (time of most recent deposit), indexed (time of most recent index), or
#       published (publication date). Note: If the API call includes a query, then the sort
#       order will be by the relevance score. If no query is included, then the sort order
#       will be by DOI update date.
#   @param order [String] Sort order, one of 'asc' or 'desc'
#   @param facet [Boolean] Include facet results. Default: false
#   @param verbose [Boolean] Print request headers to stdout. Default: false
#   @param account [String] Appveyor account name. Default: what's set in env var
#   @param project [String] Project name
#   @param version [String] Build version
#   @param verbose [Boolean] Print request headers to stdout. Default: false

# @!macro history_params
#   @param limit [String] Records per page
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
# veyor - The top level module for using methods
# to access veyor APIs
#
# The following methods, matching the main Crossref API routes, are available:
# * `veyor.works` - Use the /works endpoint
# * `veyor.members` - Use the /members endpoint
# * `veyor.prefixes` - Use the /prefixes endpoint
# * `veyor.funders` - Use the /funders endpoint
# * `veyor.journals` - Use the /journals endpoint
# * `veyor.types` - Use the /types endpoint
# * `veyor.licenses` - Use the /licenses endpoint
#
# Additional methods
# * `veyor.agency` - test the registration agency for a DOI
# * `veyor.content_negotiation` - Conent negotiation
# * `veyor.citation_count` - Citation count
# * `veyor.csl_styles` - get CSL styles
#
# All routes return an array of hashes
# For example, if you want to inspect headers returned from the HTTP request,
# and parse the raw result in any way you wish.
#
# @see https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md for
# detailed description of the Crossref API
#
# What am I actually searching when using the Crossref search API?
#
# You are using the Crossref search API described at
# https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md.
# When you search with query terms, on Crossref servers they are not
# searching full text, or even abstracts of articles, but only what is
# available in the data that is returned to you. That is, they search
# article titles, authors, etc. For some discussion on this, see
# https://github.com/CrossRef/rest-api-doc/issues/101
# * `Veyor.projects` - Use the /projects endpoint
# * `Veyor.project` - Use the /projects/{account name}/{project slug} endpoint
#
# @see http://www.appveyor.com/docs/api/projects-builds for API docs

module Veyor
  extend Configuration

  define_setting :account_name, ENV['APPVEYOR_ACCOUNT_NAME']
  define_setting :account_token, ENV['APPVEYOR_API_TOKEN']
  define_setting :base_url, "https://ci.appveyor.com"

  ##
  # Fetch projects
  #
  # @!macro veyor_options
  # @!macro veyor_params
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      Veyor.projects()
  def self.projects(options: nil, verbose: false)
    route = prep_route('projects', nil, nil, nil, nil)
    Request.new(route, nil, nil, options, verbose).get
  end

  ##
  # Get last build of a project
  #
  # @!macro veyor_options
  # @!macro veyor_params
  # @param branch [String] Branch name
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
    Request.new(route, nil, nil, options, verbose).get
  end

  ##
  # Get project history
  #
  # @!macro veyor_options
  # @!macro veyor_params
  # @!macro history_params
  # @param branch [String] Branch name
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      # get project history
  #      x = Veyor.project_history(project: 'cowsay')
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
  # @!macro veyor_options
  # @!macro veyor_params
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      # get project history
  #      x = Veyor.project_deployments(project: 'cowsay')
  #      x['deployments']
  def self.project_deployments(account: nil, project: nil, options: nil, verbose: false)
    route = sprintf('/projects/%s/%s/deployments', get_account(account), project)
    Request.new(route, nil, nil, options, verbose).get
  end

  ##
  # Get project settings
  #
  # @!macro veyor_options
  # @!macro veyor_params
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
    Request.new(route, nil, nil, options, verbose).get
  end

  ##
  # Start build of branch of most recent commit
  #
  # @!macro veyor_options
  # @!macro veyor_params
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
    Request.new('builds', nil, body, options, verbose).post
  end

  ##
  # Cancel a build
  #
  # @!macro veyor_options
  # @!macro veyor_params
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      # start a build
  #      x = Veyor.build_start(project: 'cowsay')
  #      x = Veyor.build_cancel(project: 'cowsay', version: '1.0.697')
  def self.build_cancel(account: nil, project:, version:, options: nil, verbose: false)
    route = sprintf('/builds/%s/%s/%s', get_account(account), project, version)
    Request.new(route, nil, nil, options, verbose).delete
  end

end
