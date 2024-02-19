# frozen_string_literal: true

require 'json'
require 'faye/websocket'
require 'eventmachine'

require_relative '../exceptions'

module Cryptomarket
  module Websocket
    # websocket connection manager.
    class WSManager
      def initialize(handler, url:)
        @url = url
        @handler = handler
        @connected = false
      end

      def connected?
        @connected
      end

      def connect
        @thread = Thread.new do
          EM.run do
            @ws = Faye::WebSocket::Client.new(@url)
            @ws.onopen = @on_open
            @ws.onclose = @on_close
            @ws.onerror = @on_error
            @ws.onmessage = @on_message
          end
        end
      end

      @on_open = lambda do |_event|
        @connected = true
        @handler.on_open
      end

      @on_close = lambda do |_close|
        @handler.on_close
        EM.stop
      end

      @on_error = lambda do |error|
        @handler.on_error(error)
      end

      @on_message = lambda do |message|
        @handler.handle(JSON.parse(message.data.to_s))
      end

      def close
        @ws.close
        @connected = false
      end

      def send(hash)
        raise Cryptomarket::SDKException.new, 'connection closed' unless @connected

        @ws.send hash.to_json
      end
    end
  end
end
