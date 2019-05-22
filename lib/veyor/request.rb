require "faraday"
require "multi_json"

require 'veyor/utils'
require 'veyor/helpers/configuration'

class CustomErrors < Faraday::Response::Middleware
  def on_complete(env)
    case env[:status]
    when 400
      raise Veyor::BadRequest, error_message_400(env)
    when 404
      raise Veyor::NotFound, error_message_400(env)
    when 500
      raise Veyor::InternalServerError, error_message_500(env, "Something is technically wrong.")
    when 502
      raise Veyor::BadGateway, error_message_500(env, "The server returned an invalid or incomplete response.")
    when 503
      raise Veyor::ServiceUnavailable, error_message_500(env, "Appveyor is rate limiting your requests.")
    when 504
      raise Veyor::GatewayTimeout, error_message_500(env, "504 Gateway Time-out")
    end
  end

  private

  def error_message_400(x)
    "\n   #{x.method.to_s.upcase} #{x.url.to_s}\n   Status #{x.status}#{error_body(x.body)}"
  end

  def error_body(body)
    if not body.nil? and not body.empty? and body.kind_of?(String)
      if is_json?(body)
        body = ::MultiJson.load(body)
        if body['message'].nil?
          body = nil
        else
          body = body['message']
        end
      end
    end

    if body.nil?
      nil
    else
      ": #{body}"
    end
  end

  def error_message_500(x, body=nil)
    "\n   #{x.method.to_s.upcase} #{x.url.to_s}\n   Status #{[x.status.to_s + ':', body].compact.join(' ')}"
  end

  def is_json?(string)
    MultiJson.load(string)
    return true
  rescue MultiJson::ParseError => e
    return false
  end
end

##
# veyor::Request
#
# Class to perform HTTP requests to the Appveyor API
module Veyor
  class Request

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
          f.use CustomErrors
          f.adapter  Faraday.default_adapter
        end
      else
        conn = Faraday.new(:url => Veyor.base_url, :request => self.options) do |f|
          f.request :url_encoded
          f.use CustomErrors
          f.adapter  Faraday.default_adapter
        end
      end

      conn.headers[:user_agent] = make_ua
      conn.headers["X-USER-AGENT"] = make_ua
      return conn
    end

    def _veyor_get(route, opts)
      tok = Veyor.account_token
      conn = get_conn
      conn.get do |req|
        req.url '/api/' + route
        req.params = opts
        req.headers["Content-Type"] = "application/json"
        req.headers["Authorization"] = "Bearer " + tok if tok
      end
    end

    def _veyor_post(route, body)
      tok = Veyor.account_token
      if tok.nil?
        raise 'could not find env var APPVEYOR_API_TOKEN; please set it'
      end
      conn = get_conn
      conn.post do |req|
        req.url '/api/' + route
        req.body = MultiJson.dump(body)
        req.headers["Content-Type"] = "application/json"
        req.headers["Authorization"] = "Bearer " + tok
      end
    end

    def _veyor_delete(route)
      tok = Veyor.account_token
      if tok.nil?
        raise 'could not find env var APPVEYOR_API_TOKEN; please set it'
      end
      conn = get_conn
      conn.delete do |req|
        req.url '/api/' + route
        req.headers["Authorization"] = "Bearer " + tok
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
    
  end
end
