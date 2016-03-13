require "faraday"
require "multi_json"

require "veyor/error"
require 'veyor/utils'
require 'veyor/helpers/configuration'

##
# veyor::Request
#
# Class to perform HTTP requests to the Appveyor API
module Veyor
  class Request #:nodoc:

    attr_accessor :route
    attr_accessor :account
    attr_accessor :project
    attr_accessor :options
    attr_accessor :verbose

    def initialize(route, account, project, options, verbose)
      self.account = account
      self.project = project
      self.options = options
      self.verbose = verbose
    end

    def perform
      # args = { query: self.query, filter: filt, offset: self.offset,
      #         rows: self.limit, sample: self.sample, sort: self.sort,
      #         order: self.order, facet: self.facet }
      # opts = args.delete_if { |k, v| v.nil? }

      # body = { :accountName => 'sckott', :projectSlug => 'cowsay', :branch => 'master' }

      if verbose
        conn = Faraday.new(:url => Veyor.base_url, :request => options) do |f|
          f.request :url_encoded
          f.response :logger
          f.adapter  Faraday.default_adapter
          f.use FaradayMiddleware::RaiseHttpException
        end
      else
        conn = Faraday.new(:url => Veyor.base_url, :request => options) do |f|
          f.request :url_encoded
          f.adapter  Faraday.default_adapter
          f.use FaradayMiddleware::RaiseHttpException
        end
      end

      conn.headers[:user_agent] = make_ua
      conn.headers["X-USER-AGENT"] = make_ua

      res = veyor_get(self.route)
      return MultiJson.load(res.body)
    end
  end
end

def veyor_get(route)
  conn.get do |req|
    req.url '/api/' + route
    req.headers["Content-Type"] = "application/json"
    req.headers["Authorization"] = "Bearer " + Veyor.account_token
  end
end

def veyor_post
  conn.post do |req|
    req.url '/api/builds'
    req.headers["Content-Type"] = "application/json"
    req.headers["Authorization"] = "Bearer " + Veyor.account_token
    req.body = body
  end
end
