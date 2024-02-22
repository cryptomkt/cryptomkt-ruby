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
            @ws.onopen = method(:_on_open)
            @ws.onclose = method(:_on_close)
            @ws.onerror = method(:_on_error)
            @ws.onmessage = method(:_on_message)
          end
        end
      end

      def _on_open(_open_event)
        @connected = true
        @handler.on_open
      end

      def _on_close(_close_event)
        @handler.on_close
        EM.stop
      end

      def _on_error(error)
        @handler.on_error(error)
      end

      def _on_message(message)
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
