require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'rest-client'
require 'date'
require_relative 'exceptions'

module Cryptomarket
  # Builds a credential used by the cryptomarket server
  class CredentialFactory
    def initialize(api_key:, api_secret:, window: nil)
      @api_key = api_key
      @api_secret = api_secret
      @window = window
    end

    def get_credential(http_method, method, params)
      timestamp = DateTime.now.strftime('%Q')
      msg = build_credential_message(http_method, method, timestamp, params)
      digest = OpenSSL::Digest.new 'sha256'
      signature = OpenSSL::HMAC.hexdigest digest, @api_secret, msg
      signed = "#{@api_key}:#{signature}:#{timestamp}"
      signed += ":#{@window}" unless @window.nil?
      encoded = Base64.encode64(signed).delete "\n"
      "HS256 #{encoded}"
    end

    def build_credential_message(http_method, method, timestamp, params)
      msg = http_method + @@api_version + method
      msg += if http_method.upcase == 'POST'
               params
             else
               not_post_params(http_method, params)
             end
      msg += timestamp
      msg += @window unless @window.nil?
      msg
    end

    def not_post_params(http_method, params)
      msg = ''
      if !params.nil? && params.keys.any?
        msg += '?' if http_method.upcase == 'GET'
        msg += URI.encode_www_form(params)
      end
      msg
    end
  end
end
