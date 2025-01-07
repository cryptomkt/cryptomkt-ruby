# frozen_string_literal: true

require_relative 'callback_cache'
require_relative 'ws_manager'
require_relative '../exceptions'

module Cryptomarket
  module Websocket
    # websockt client able to handle requests and subscriptions
    class ClientBase
      def initialize(url:, subscription_keys:, on_connect: -> {}, on_error: ->(error) {}, on_close: -> {})
        @subscription_keys = subscription_keys
        @callback_cache = CallbackCache.new
        @ws_manager = WSManager.new(self, url:)
        @on_connect = on_connect
        @on_error = on_error
        @on_close = on_close
      end

      def connected?
        @ws_manager.connected?
      end

      # connects via websocket to the exchange, it blocks until the connection is stablished
      def connect
        @ws_manager.connect
        sleep(1) until @ws_manager.connected?
      end

      def on_open
        @on_connect.call
      end

      def on_connect=(callback = nil, &block)
        callback ||= block
        @on_connect = callback
      end

      def on_connect
        @on_connect.call
      end

      def on_error=(callback = nil, &block)
        callback ||= block
        @on_error = callback
      end

      def on_error(error)
        @on_error.call(error)
      end

      def on_close=(callback = nil, &block)
        callback ||= block
        @on_close = callback
      end

      def on_close
        @on_close.call
      end

      def close
        @ws_manager.close
      end

      def send_subscription(method, callback, params, result_callback)
        @callback_cache.store_subscription_callback(@subscription_keys[method][0], callback)
        store_callback_and_send(method, params, result_callback)
      end

      def send_unsubscription(method, callback, params)
        @callback_cache.delete_subscription_callback(@subscription_keys[method][0])
        store_callback_and_send(method, params, callback)
      end

      def request(method, callback, params = {}, call_count = 1)
        store_callback_and_send(method, params, callback, call_count)
      end

      def store_callback_and_send(method, params, callback_to_store = nil, call_count = 1)
        params = params.compact unless params.nil?
        payload = { 'method' => method, 'params' => params }
        unless callback_to_store.nil?
          id = @callback_cache.store_callback(callback_to_store, call_count)
          payload['id'] = id
        end
        @ws_manager.send(payload)
      end

      def handle(message)
        if message.key? 'id'
          handle_response(message)
        elsif message.key? 'method'
          handle_notification(message)
        end
      end

      def handle_notification(notification)
        method = notification['method']
        method_data = @subscription_keys[method]
        notification_type = method_data[1]
        callback = @callback_cache.get_subscription_callback(method_data[0])
        return if callback.nil?

        callback.call(notification['params'], notification_type)
      end

      def get_callback_for_response(response)
        id = response['id']
        return if id.nil?

        @callback_cache.get_callback(id)
      end

      def handle_response(response)
        callback = get_callback_for_response(response)
        return if callback.nil?

        if response.key? 'error'
          callback.call(Cryptomarket::APIException.new(response['error']), nil)
          nil
        end
        handle_good_response(response, callback)
      end

      def handle_good_response(response, callback)
        result = response['result']
        if result.is_a?(Hash) && result.key?('data')
          callback.call(nil, result['data'])
        else
          callback.call(nil, result)
        end
      end
    end
  end
end
