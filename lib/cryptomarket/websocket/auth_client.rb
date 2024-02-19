# frozen_string_literal: true

require 'securerandom'
require_relative 'client_base'

module Cryptomarket
  module Websocket
    # A websocket client that authenticates at the moment of connection
    class AuthClient < ClientBase
      # Creates a new client
      def initialize(url:, api_key:, api_secret:, subscription_keys:, window: nil)
        @api_key = api_key
        @api_secret = api_secret
        @window = window
        super url: url, subscription_keys: subscription_keys
        @authed = false
      end

      def connected?
        (super.connected? and @authed)
      end

      # connects via websocket to the exchange and authenticates it.
      def connect
        super
        authenticate(proc { |err, _result|
          raise err unless err.nil?

          @authed = true
        })
        wait_authed
      end

      def wait_authed
        current_try = 0
        max_tries = 60
        while !@authed && (current_try < max_tries)
          current_try += 1
          sleep(1)
        end
      end

      # Authenticates the websocket
      #
      # https://api.exchange.cryptomkt.com/#socket-session-authentication
      #
      # +Proc+ +callback+:: Optional. A +Proc+ to call with the result data. It takes two arguments, err and result.
      # err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}

      def authenticate(callback = nil)
        timestamp = Time.now.to_i * 1000
        digest = OpenSSL::Digest.new 'sha256'
        message = timestamp.to_s
        message += @window.to_s unless @window.nil?
        signature = OpenSSL::HMAC.hexdigest digest, @api_secret, message.to_s
        params = build_auth_payload timestamp, signature
        request('login', callback, params)
      end

      def build_auth_payload(timestamp, signature)
        params = {
          'type' => 'HS256',
          'api_key' => @api_key,
          'timestamp' => timestamp,
          'signature' => signature
        }
        params['window'] = @window unless @window.nil?
        params
      end
    end
  end
end
