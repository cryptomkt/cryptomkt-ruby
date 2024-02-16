require_relative "reusableCallback"

module Cryptomarket
    module Websocket
        class CallbackCache 
            def initialize() 
                @reusable_callbacks = Hash.new
                @next_id = 1
            end

            def get_next_id
                _next_id = @next_id
                @next_id+= 1
                if @next_id < 0
                    @next_id = 1
                end
                return _next_id
            end

            def store_callback(callback, call_count=1)
                id = get_next_id()
                @reusable_callbacks[id] = ReusableCallback.new(callback, call_count)
                return id
            end

            def get_callback(id)
                if not @reusable_callbacks.has_key? id
                    return nil
                end
                callback, done_using = @reusable_callbacks[id].get_callback()
                if done_using 
                    @reusable_callbacks.delete(id)
                end
                return callback
            end

            def store_subscription_callback(key, callback) 
                @reusable_callbacks[key] = callback
            end

            def get_subscription_callback(key)
                if not @reusable_callbacks.has_key? key
                    return nil
                end
                return @reusable_callbacks[key]
            end

            def delete_subscription_callback(key) 
                if @reusable_callbacks.has_key? key
                    @reusable_callbacks.delete(key)
                end
            end
        end
    end
end