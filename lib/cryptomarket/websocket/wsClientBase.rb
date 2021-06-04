require_relative "callbackCache"
require_relative "methods"
require_relative "orderbookCache"
require_relative "wsManager"
require_relative '../exceptions'

module Cryptomarket
    module Websocket
        class ClientBase
            include Methods

            def initialize(url:)
                @callbackCache = CallbackCache.new
                @wsmanager = WSManager.new self, url:url
                @onconnect = ->{}
                @onerror = ->(error){}
                @onclose = ->{}
            end

            def connected?
                return @wsmanager.connected?
            end

            def close()
                @wsmanager.close()
            end

            # connects via websocket to the exchange, it blocks until the connection is stablished
            def connect()
                @wsmanager.connect()
                while (not @wsmanager.connected?)
                    sleep(1)
                end
            end

            def on_open()
                @onconnect.call()
            end

            def onconnect=(callback=nil, &block)
                callback = callback || block
                @onconnect = callback
            end

            def onconnect()
                @onconnect.call()
            end

            def onerror=(callback=nil, &block)
                callback = callback || block
                @onerror = callback
            end

            def onerror(error)
                @onerror.call(error)
            end

            def onclose=(callback=nil, &block)
                callback = callback || block
                @onclose = callback
            end

            def onclose()
                @onclose.call()
            end

            def sendSubscription(method, callback, params, resultCallback)
                key = buildKey(method, params)
                @callbackCache.storeSubscriptionCallback(key, callback)
                storeAndSend(method, params, resultCallback)
            end

            def sendUnsubscription(method, callback, params)
                key = buildKey(method, params)
                @callbackCache.deleteSubscriptionCallback(key)
                storeAndSend(method, params, callback)
            end
            
            def sendById(method, callback, params={})
                storeAndSend(method, params, callback)
            end
            
            def storeAndSend(method, params, callbackToStore=nil)
                payload = {'method' => method, 'params' => params}
                if not callbackToStore.nil?
                    id = @callbackCache.storeCallback(callbackToStore)
                    payload['id'] = id
                end
                @wsmanager.send(payload)
            end

            def handle(message)
                if message.has_key? 'method'
                    handleNotification(message)
                elsif message.has_key? 'id'
                    handleResponse(message)
                end
            end

            def handleNotification(notification)
                key = "subscription"
                callback = @callbackCache.getSubscriptionCallback(key)
                if callback.nil?
                    return
                end
                callback.call(notification["params"]) 
            end
            
            def buildKey(method=nil, params=nil)
                return "subscription"
            end

            def handleResponse(response)
                id = response['id']
                if id.nil? 
                    return 
                end
                callback = @callbackCache.popCallback(id)
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

            def handleNotification(notification)
                key = "subscription"
                callback = @callbackCache.getSubscriptionCallback(key)
                if callback.nil?
                    return
                end
                if notification["params"].kind_of?(Array)
                    notification["params"].each{|feed| callback.call(feed)}
                else
                    callback.call(notification["params"]) 
                end
            end

            def buildKey(method=nil, params=nil)
                return "subscription"
            end

            def close()
                @wsmanager.close()
            end
        end
    end
end