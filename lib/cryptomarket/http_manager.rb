require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'rest-client'
require_relative 'exceptions'

module Cryptomarket
  class HttpManager
    @@apiUrl = 'https://api.exchange.cryptomkt.com'
    @@apiVersion = '/api/3/'

    def initialize(apiKey:, apiSecret:, window:nil)
      @apiKey = apiKey
      @apiSecret = apiSecret
      @window = window
    end

    def getCredential(httpMethod, method, params)
        timestamp = Time.now.to_i.to_s + "000"
        msg = httpMethod + @@apiVersion + method
        if not params.nil? and params.keys.any?
          if httpMethod.upcase == 'GET'
            msg += '?'
          end
          msg += URI.encode_www_form params
        end
        msg += timestamp
        if not @window.nil?
          msg += @window
        end
        digest = OpenSSL::Digest.new 'sha256'
        signature = OpenSSL::HMAC.hexdigest digest, @apiSecret, msg
        signed = @apiKey  + ':' + signature + ':' + timestamp
        if not @window.nil?
          signed += (':' + @window)
        end
        encoded = Base64.encode64(signed).delete "\n"
        return 'HS256 ' + encoded
    end

    def makeRequest(method:, endpoint:, params:nil, public:false)
        if !params.nil?
          params = params.compact
        end
        uri = URI(@@apiUrl + @@apiVersion + endpoint)
        if not params.nil?
          params = Hash[params.sort_by {|key, val| key.to_s }]
        end
        headers = Hash.new
        if not public
          headers['Authorization'] = getCredential(method.upcase, endpoint, params)
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
          return handleResponse(response)
        rescue RestClient::ExceptionWithResponse => e
          response = e.response
          return handleResponse(response)
        end
    end

    def handleResponse(response)
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
