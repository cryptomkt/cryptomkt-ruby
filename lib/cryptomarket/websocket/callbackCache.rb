module Cryptomarket
    module Websocket
        class CallbackCache 
            def initialize() 
                @callbacks = Hash.new
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

            def store_callback(callback)
                id = get_next_id()
                @callbacks[id] = callback
                return id
            end

            def pop_callback(id)
                if not @callbacks.has_key? id
                    return nil
                end
                callback = @callbacks[id]
                @callbacks.delete(id)
                return callback
            end

            def store_subscription_callback(key, callback) 
                @callbacks[key] = callback
            end

            def get_subscription_callback(key)
                if not @callbacks.has_key? key
                    return nil
                end
                return @callbacks[key]
            end

            def delete_subscription_callback(key) 
                if @callbacks.has_key? key
                    @callbacks.delete(key)
                end
            end
        end
    end
end