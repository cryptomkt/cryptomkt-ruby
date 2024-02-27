# frozen_string_literal: true

module Cryptomarket
  module Websocket
    # A wrapper for a callback, enable reuse of a callback up to an n number of times, and signals when is done reusing.
    class ReusableCallback
      def initialize(callback, call_count)
        @call_count = call_count
        @callback = callback
      end

      def get_callback # rubocop:disable Naming/AccessorMethodName
        return [nil, false] if @call_count < 1

        @call_count -= 1
        done_using = @call_count < 1
        [@callback, done_using]
      end
    end
  end
end
