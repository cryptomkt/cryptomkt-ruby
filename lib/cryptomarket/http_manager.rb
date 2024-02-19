# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'base64'
require 'rest-client'
require 'date'
require_relative 'exceptions'
require_relative 'credential_factory'

module Cryptomarket
  # Manager of http requests to the cryptomarket server
  class HttpManager
    Request = Data.define(:uri, :endpoint, :payload, :headers, :is_json)
    @@API_URL = 'https://api.exchange.cryptomkt.com' # rubocop:disable Naming/VariableName,Style/ClassVars
    @@API_VERSION = '/api/3/' # rubocop:disable Naming/VariableName,Style/ClassVars

    def initialize(api_key:, api_secret:, window: nil)
      @credential_factory = CredentialFactory(api_key, api_secret, window)
    end

    def make_request(method:, endpoint:, params: nil, public: false)
      uri = URI(@@API_URL + version_as_str + endpoint)
      payload = build_payload(params)
      headers = build_headers(method, endpoint, params, public)
      if ((method.upcase == 'GET') || (method.upcase == 'PUT')) && !payload.nil?
        payload = nil
        uri.query = URI.encode_www_form payload
      end
      do_request(Request[method, uri, payload, headers, false])
    end

    def make_post_request(method:, endpoint:, params: nil)
      uri = URI(@@API_URL + version_as_str + endpoint)
      payload = build_payload(params)
      do_request(Request[method, uri, payload, build_post_headers(endpoint, payload), true])
    end

    def build_headers(method, endpoint, params, public)
      return {} if public

      { 'Authorization' => @credential_factory.get_credential(method.upcase, endpoint, params) }
    end

    def build_payload(params)
      return nil if params.nil?

      payload = params.compact
      payload = Hash[params.sort_by { |key, _val| key.to_s }] if params.is_a?(Hash)
      payload
    end

    def do_request(request:)
      response = RestClient::Request.execute(
        method: request.method.downcase.to_sym, url: request.uri.to_s,
        payload: request.payload.to_json, headers: request.headers
      )
      response[:content_type] = :json if request.is_json
      handle_response(response)
    rescue RestClient::ExceptionWithResponse => e
      handle_response(e.response)
    end

    def build_post_headers(endpoint, params)
      { 'Content-Type' => 'application/json',
        'Authorization' => @credential_factory.get_credential('POST'.upcase, endpoint, params.to_json) }
    end

    def handle_response(response)
      result = response.body
      parsed_result = JSON.parse result
      if (response.code != 200) && !parsed_result['error'].nil?
        error = parsed_result['error']
        msg = "(code=#{error['code']}): #{error['message']}"
        msg += ": #{error['description']}" unless error['description'].nil?
        exception = Cryptomarket::APIException.new error
        raise exception, msg
      end
      parsed_result
    end
  end
end