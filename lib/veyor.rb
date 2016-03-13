require "veyor/version"
require "veyor/request"
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

module Veyor
  extend Configuration

  define_setting :account_name, ENV['APPVEYOR_ACCOUNT_NAME']
  define_setting :account_token, ENV['APPVEYOR_API_TOKEN']
  define_setting :base_url, "https://ci.appveyor.com"

  ##
  # Fetch projects
  #
  # @!macro veyor_options
  # @return [Array] An array of hashes
  #
  # @example
  #      require 'veyor'
  #      veyor.projects(ids: '10.5555/515151')
  def self.projects(options: nil)
    Request.new('projects', nil, nil, options, verbose).perform
  end

end
