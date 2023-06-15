require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'rest-client'
require 'date'
require_relative 'exceptions'

module Cryptomarket
  class HttpManager
    @@api_url = 'https://api.exchange.cryptomkt.com'
    @@api_version = '3'
    
    def initialize(api_key:, api_secret:, window:nil)
      @api_key = api_key
      @api_secret = api_secret
      @window = window
    end

    def version_as_str
      return '/api/' + @@api_version + '/'
    end

    def not_post_params(http_method, params)
      msg = ''
      if not params.nil? and params.keys.any?
        if http_method.upcase == 'GET'
          msg += '?'
        end
        msg += URI.encode_www_form(params)
      end
      return msg
    end

    def get_credential(http_method, method, params)
        timestamp = DateTime.now.strftime('%Q')
        msg = http_method + version_as_str + method
        if http_method.upcase == 'POST'
          msg += params
        else 
          msg += not_post_params(http_method, params)
        end
        msg += timestamp
        if not @window.nil?
          msg += @window
        end
        digest = OpenSSL::Digest.new 'sha256'
        signature = OpenSSL::HMAC.hexdigest digest, @api_secret, msg
        signed = @api_key  + ':' + signature + ':' + timestamp
        if not @window.nil?
          signed += (':' + @window)
        end
        encoded = Base64.encode64(signed).delete "\n"
        return 'HS256 ' + encoded
    end

    def make_request(method:, endpoint:, params:nil, public:false)
        if !params.nil?
          params = params.compact
        end
        uri = URI(@@api_url + version_as_str + endpoint)
        if not params.nil?
          params = Hash[params.sort_by {|key, val| key.to_s }]
        end
        if (method.upcase == 'POST')
          return post(uri:uri, endpoint:endpoint, params:params)
        end
        headers = Hash.new
        if not public
          headers['Authorization'] = get_credential(method.upcase, endpoint, params)
        end
        if (method.upcase == 'GET' or method.upcase =='PUT') and not params.nil?
          uri.query = URI.encode_www_form params
          params = nil
        end
        
        begin
          response = RestClient::Request.execute(
            method: method.downcase.to_sym,
            url: uri.to_s,
            payload: params,
            headers: headers)
          return handle_response(response)
        rescue RestClient::ExceptionWithResponse => e
          response = e.response
          return handle_response(response)
        end
    end

    def post(uri:, endpoint:, params:)
        headers = Hash.new
        headers['Content-Type'] = 'application/json'
        headers['Authorization'] = get_credential("POST".upcase, endpoint, params.to_json)
        begin
          response = RestClient::Request.execute(
            method: "POST".downcase.to_sym,
            url: uri.to_s,
            payload: params.to_json,
            headers: headers,
            content_type: :json)
          return handle_response(response)
        rescue RestClient::ExceptionWithResponse => e
          response = e.response
          return handle_response(response)
        end
    end

    def handle_response(response)
      result = response.body
      parsed_result = JSON.parse result
      if response.code != 200 and not parsed_result['error'].nil?
        error = parsed_result['error']
        msg = "(code=#{error['code']}): #{error['message']}"
        if not error['description'].nil?
          msg += ": #{error['description']}"
        end
        exception = Cryptomarket::APIException.new error
        raise exception, msg
      end
      return parsed_result
    end
  end
end
