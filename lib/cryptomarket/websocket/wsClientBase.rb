require_relative "callbackCache"
require_relative "orderbookCache"
require_relative "wsManager"
require_relative '../exceptions'

module Cryptomarket
    module Websocket
        class ClientBase
            def initialize(url:, subscription_keys:)
                @subscription_keys = subscription_keys
                @callback_cache = CallbackCache.new
                @ws_manager = WSManager.new self, url:url
                @on_connect = ->{}
                @on_error = ->(error){}
                @on_close = ->{}
            end

            def connected?
                return @ws_manager.connected?
            end

            def close()
                @ws_manager.close()
            end

            # connects via websocket to the exchange, it blocks until the connection is stablished
            def connect()
                @ws_manager.connect()
                while (not @ws_manager.connected?)
                    sleep(1)
                end
            end

            def on_open()
                @on_connect.call()
            end

            def on_connect=(callback=nil, &block)
                callback = callback || block
                @on_connect = callback
            end

            def on_connect()
                @on_connect.call()
            end

            def on_error=(callback=nil, &block)
                callback = callback || block
                @on_error = callback
            end

            def on_error(error)
                @on_error.call(error)
            end

            def on_close=(callback=nil, &block)
                callback = callback || block
                @on_close = callback
            end

            def on_close()
                @on_close.call()
            end

            def close()
              @ws_manager.close()
            end

            def send_subscription(method, callback, params, result_callback)
                method_data = @subscription_keys[method]
                key = method_data[0]
                @callback_cache.store_subscription_callback(key, callback)
                store_and_send(method, params, result_callback)
            end

            def send_unsubscription(method, callback, params)
                method_data = @subscription_keys[method]
                key = method_data[0]
                @callback_cache.delete_subscription_callback(key)
                store_and_send(method, params, callback)
            end

            def send_by_id(method, callback, params={}, call_count=1)
                store_and_send(method, params, callback, call_count)
            end

            def store_and_send(method, params, callback_to_store=nil, call_count=1)
                if !params.nil?
                  params = params.compact
                end
                payload = {'method' => method, 'params' => params}
                if not callback_to_store.nil?
                  id = @callback_cache.store_callback(callback_to_store, call_count)
                  payload['id'] = id
                end
                @ws_manager.send(payload)
            end

            def handle(message)
                if message.has_key? 'id'
                    handle_response(message)
                elsif message.has_key? 'method'
                        handle_notification(message)
                end
            end

            def handle_notification(notification)
                method = notification['method']
                method_data = @subscription_keys[method]
                key = method_data[0]
                notification_type = method_data[1]
                callback = @callback_cache.get_subscription_callback(key)
                if callback.nil?
                    return
                end
                callback.call(notification["params"], notification_type)
            end

            def handle_response(response)
                id = response['id']
                if id.nil?
                    return
                end
                callback = @callback_cache.get_callback(id)
                if callback.nil?
                    return
                end
                if response.has_key? 'error'
                    callback.call(Cryptomarket::APIException.new(response['error']), nil)
                    return
                elsif
                    result = response['result']
                    if result.is_a?(Hash) and result.has_key? 'data'
                        callback.call(nil, result['data'])
                    else
                        callback.call(nil, result)
                    end
                end
            end
        end
    end
end