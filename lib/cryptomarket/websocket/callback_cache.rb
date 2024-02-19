# frozen_string_literal: true

require_relative 'reusable_callback'

module Cryptomarket
  module Websocket
    # A cache store for callbacks. uses reusable callbacks, so it cans use a callback for more than one time.
    # Each callback stored
    class CallbackCache
      def initialize
        @reusable_callbacks = {}
        @next_id = 1
      end

      def _get_next_id
        next_id = @next_id
        @next_id += 1
        @next_id = 1 if @next_id.negative?
        next_id
      end

      def store_callback(callback, call_count = 1)
        id = _get_next_id
        @reusable_callbacks[id] = ReusableCallback.new(callback, call_count)
        id
      end

      def get_callback(id)
        return nil unless @reusable_callbacks.key? id

        callback, done_using = @reusable_callbacks[id].get_callback
        @reusable_callbacks.delete(id) if done_using
        callback
      end

      def store_subscription_callback(key, callback)
        @reusable_callbacks[key] = callback
      end

      def get_subscription_callback(key)
        return nil unless @reusable_callbacks.key? key

        @reusable_callbacks[key]
      end

      def delete_subscription_callback(key)
        return unless @reusable_callbacks.key? key

        @reusable_callbacks.delete(key)
      end
    end
  end
end
