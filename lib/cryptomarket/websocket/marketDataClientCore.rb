require 'securerandom'

require_relative 'client_base'
require_relative '../constants'

module Cryptomarket
  module Websocket
    # websocket client able to handle market data subscriptions
    class MarketDataClientCore < ClientBase
      def initialize
        super(
          url: 'wss://api.exchange.cryptomkt.com/api/3/ws/public',
          subscription_keys: {})
      end

      def send_channel_subscription(channel, callback, result_callback, params = {})
        params = params.compact unless params.nil?
        payload = { 'method' => 'subscribe', 'ch' => channel, 'params' => params }

        key = channel
        @callback_cache.store_subscription_callback(key, callback)
        unless result_callback.nil?
          id = @callback_cache.store_callback(result_callback)
          payload['id'] = id
        end
        @ws_manager.send(payload)
      end

      def handle(message)
        if message.key? 'ch'
          handle_ch_notification(message)
        elsif message.key? 'id'
          handle_response(message)
        end
      end

      def handle_ch_notification(notification)
        key = notification['ch']
        callback = @callback_cache.get_subscription_callback(key)
        return if callback.nil?

        callback.call(notification['data'], Args::NotificationType::DATA) if notification.key? 'data'
        callback.call(notification['snapshot'], Args::NotificationType::SNAPSHOT) if notification.key? 'snapshot'
        return unless notification.key? 'update'

        callback.call(notification['update'], Args::NotificationType::UPDATE)
      end

      def intercept_result_callback(result_callback)
        return result_callback if result_callback.nil?

        proc { |err, result|
          if result.nil?
            result_callback.call(err, result)
          else
            result_callback.call(err, result['subscriptions'])
          end
        }
      end
    end
  end
end
