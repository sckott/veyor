require "faraday"
require 'faraday_middleware'
require "multi_json"

require 'veyor/faraday'
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
    attr_accessor :args
    attr_accessor :body
    attr_accessor :options
    attr_accessor :verbose

    def initialize(route, args, body, options, verbose)
      self.route   = route
      self.args    = args
      self.body    = body
      self.options = options
      self.verbose = verbose
    end

    def get_conn
      # if args.nil?
      #   args = {}
      # end

      if self.verbose
        conn = Faraday.new(:url => Veyor.base_url, :request => self.options) do |f|
          f.request :url_encoded
          f.response :logger
          f.adapter  Faraday.default_adapter
        end
      else
        conn = Faraday.new(:url => Veyor.base_url, :request => self.options) do |f|
          f.request :url_encoded
          f.adapter  Faraday.default_adapter
        end
      end

      conn.headers[:user_agent] = make_ua
      conn.headers["X-USER-AGENT"] = make_ua
      return conn
    end

    def _veyor_get(route, opts)
      conn = get_conn
      conn.get do |req|
        req.url '/api/' + route
        req.params = opts
        req.headers["Content-Type"] = "application/json"
        req.headers["Authorization"] = "Bearer " + Veyor.account_token
      end
    end

    def _veyor_post(route, body)
      conn = get_conn
      conn.post do |req|
        req.url '/api/' + route
        req.body = MultiJson.dump(body)
        req.headers["Content-Type"] = "application/json"
        req.headers["Authorization"] = "Bearer " + Veyor.account_token
      end
    end

    def _veyor_delete(route)
      conn = get_conn
      conn.delete do |req|
        req.url '/api/' + route
        req.headers["Authorization"] = "Bearer " + Veyor.account_token
      end
    end

    def parse_result(z)
      if z.headers['content-type'].match('json').nil?
        return z.body
      else
        return MultiJson.load(z.body)
      end
    end

    def get
      res = _veyor_get(self.route, self.args)
      return parse_result(res)
    end

    def post
      res = _veyor_post(self.route, self.body)
      return parse_result(res)
    end

    def delete
      return _veyor_delete(self.route).status
    end

    # def perform
    #   if self.args.nil?
    #     self.args = {}
    #   end

    #   if verbose
    #     conn = Faraday.new(:url => Veyor.base_url, :request => options) do |f|
    #       f.request :url_encoded
    #       f.response :logger
    #       f.adapter  Faraday.default_adapter
    #       # f.use FaradayMiddleware::RaiseHttpException
    #     end
    #   else
    #     conn = Faraday.new(:url => Veyor.base_url, :request => options) do |f|
    #       f.request :url_encoded
    #       f.adapter  Faraday.default_adapter
    #       # f.use FaradayMiddleware::RaiseHttpException
    #     end
    #   end

    #   conn.headers[:user_agent] = make_ua
    #   conn.headers["X-USER-AGENT"] = make_ua
    # end

  end
end
