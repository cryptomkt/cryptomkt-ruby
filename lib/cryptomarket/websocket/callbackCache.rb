module Cryptomarket
    module Websocket
        class CallbackCache 
            def initialize() 
                @callbacks = Hash.new
                @nextId = 1
            end

            def getNextId
                _nextId = @nextId
                @nextId+= 1
                if @nextId < 0
                    @nextId = 1
                end
                return _nextId
            end

            def storeCallback(callback)
                id = getNextId()
                @callbacks[id] = callback
                return id
            end

            def popCallback(id)
                if not @callbacks.has_key? id
                    return nil
                end
                callback = @callbacks[id]
                @callbacks.delete(id)
                return callback
            end

            def storeSubscriptionCallback(key, callback) 
                @callbacks[key] = callback
            end

            def getSubscriptionCallback(key)
                if not @callbacks.has_key? key
                    return nil
                end
                return @callbacks[key]
            end

            def deleteSubscriptionCallback(key) 
                if @callbacks.has_key? key
                    @callbacks.delete(key)
                end
            end
        end
    end
end