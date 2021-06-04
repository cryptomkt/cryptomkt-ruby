require "securerandom"

require_relative "wsClientBase"
require_relative"../utils"
require_relative "methods"




module Cryptomarket
    module Websocket
        # PublicClient connects via websocket to cryptomarket to get market information of the exchange.
        #
        # +Proc+ +callback+:: Optional. A +Proc+ to call with the client once the connection is established. if an error ocurrs is return as the fist parameter of the callback: callback(err, client)
        
        class PublicClient < ClientBase
            include Utils
            include Methods

            def initialize()
                @OBCache = OrderbookCache.new
                super url:"wss://api.exchange.cryptomkt.com/api/2/ws/public"
            end

            def handleNotification(notification)
                method = notification['method']
                params = notification['params']
                key = buildKey(method, params)
                callback = @callbackCache.getSubscriptionCallback(key)
                if callback.nil?
                    return
                end
                if orderbookFeed(method)
                    @OBCache.update(method, key, params)
                    if @OBCache.orderbookBroken(key)
                        storeAndSend('subscribeOrderbook', {'symbol' => params['symbol']}, nil)
                        @OBCache.waitOrderbook(key)
                        return
                    end
                    if @OBCache.orderbookWating(key)
                        return
                    end
                    params = @OBCache.getOrderbook(key)
                end
                if candlesFeed(method) or tradesFeed(method)
                    params = params["data"]
                end
                callback.call(params) 
            end

            def buildKey(method, params)
                methodKey = mapping(method)

                symbol =  ''
                if params.has_key? 'symbol'
                    symbol = params['symbol']
                end
                period = ''
                if params.has_key? 'period'
                    period = params['period']
                end
                key = methodKey + ':' + symbol + ':' + period
                return key.upcase
            end

            # Get a list all available currencies on the exchange
            # 
            # https://api.exchange.cryptomkt.com/#get-currencies
            # 
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def getCurrencies(callback)
                sendById("getCurrencies", callback)
            end

            # Get the data of a currency
            # 
            # https://api.exchange.cryptomkt.com/#get-currencies
            # 
            # +String+ +currency+:: A currency id
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def getCurrency(currency, callback)
                sendById('getCurrency', callback, {'currency' => currency})
            end

            # Get a list of the specified symbols or all of them if no symbols are specified
            # 
            # A symbol is the combination of the base currency (first one) and quote currency (second one)
            # 
            # https://api.exchange.cryptomkt.com/#get-symbols
            # 
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def getSymbols(callback)
                sendById('getSymbols', callback)
            end

            # Get a symbol by its id
            # 
            # A symbol is the combination of the base currency (first one) and quote currency (second one)
            # 
            # https://api.exchange.cryptomkt.com/#get-symbols
            # 
            # 
            # +String+ +symbol+:: A symbol id
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def getSymbol(symbol, callback)
                sendById('getSymbol', callback, {'symbol' => symbol})
            end

            # Subscribe to a ticker of a symbol
            # 
            # https://api.exchange.cryptomkt.com/#subscribe-to-ticker
            # 
            # +String+ +symbol+:: A symbol to subscribe
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes one argument. The ticker feed
            # +Proc+ +resultCallback+:: Optional. A function to call with the subscription result. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def subscribeToTicker(symbol, callback, resultCallback=nil)
                sendSubscription('subscribeTicker', callback, {'symbol' => symbol}, resultCallback)
            end

            # Unsubscribe to a ticker of a symbol
            # 
            # https://api.exchange.cryptomkt.com/#subscribe-to-ticker
            # 
            # 
            # +String+ +symbol+:: The symbol to stop the ticker subscribption
            # +Proc+ +callback+:: Optional. A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def unsubscribeToTicker(symbol, callback=nil)
                sendUnsubscription('unsubscribeTicker', callback, {'symbol' => symbol})
            end

            # Subscribe to the order book of a symbol
            # 
            # An Order Book is an electronic list of buy and sell orders for a specific symbol, structured by price level
            # 
            # https://api.exchange.cryptomkt.com/#subscribe-to-order-book
            # 
            # +String+ +symbol+:: The symbol of the orderbook
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes one argument. the order book feed
            # +Proc+ +resultCallback+:: A function to call with the subscription result. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def subscribeToOrderbook(symbol, callback, resultCallback=nil)
                sendSubscription('subscribeOrderbook', callback, {'symbol' => symbol}, resultCallback)
            end

            # Unsubscribe to an order book of a symbol
            # 
            # An Order Book is an electronic list of buy and sell orders for a specific symbol, structured by price level
            # 
            # https://api.exchange.cryptomkt.com/#subscribe-to-order-book
            # 
            # +String+ +symbol+:: The symbol of the orderbook
            # +Proc+ +callback+:: Optional. A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def unsubscribeToOrderbook(symbol, callback=nil)
                sendUnsubscription('unsubscribeOrderbook', callback, {'symbol' => symbol})
            end

            # Subscribe to the trades of a symbol
            # 
            # https://api.exchange.cryptomkt.com/#subscribe-to-trades
            # 
            # +String+ +symbol+:: The symbol of the trades
            # +Integer+ [limit] Optional. Maximum number of trades in the first feed, the nexts feeds have one trade
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes one argument. the trades feed
            # +Proc+ +resultCallback+:: Optional. A function to call with the subscription result. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def subscribeToTrades(symbol, callback, limit=nil, resultCallback=nil)
                params = {'symbol' => symbol}
                sendSubscription('subscribeTrades', callback, params, resultCallback)
            end
            
            # Unsubscribe to a trades of a symbol
            # 
            # https://api.exchange.cryptomkt.com/#subscribe-to-trades
            # 
            # +String+ +symbol+:: The symbol of the trades
            # +Proc+ +callback+:: Optional. A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def unsubscribeToTrades(symbol, callback=nil)
                sendUnsubscription('unsubscribeTrades', callback, {'symbol' => symbol})
            end


            # Get trades of the specified symbol
            # 
            # https://api.exchange.cryptomkt.com/#get-trades
            # 
            # +String+ +symbol+:: The symbol to get the trades
            # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
            # +String+ +from+:: Optional. Initial value of the queried interval.
            # +String+ +till+:: Optional. Last value of the queried interval.
            # +Integer+ +limit+:: Optional. Trades per query. Defaul is 100. Max is 1000
            # +Integer+ +offset+:: Optional. Default is 0. Max is 100000
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def getTrades(symbol, callback, from:nil, till:nil, limit:nil, offset:nil)
                params = {'symbol' => symbol}
                extend_hash_with_pagination! params, from:from, till:till, limit:limit, offset:offset
                sendById('getTrades', callback, params)
            end
            
            # Subscribe to the candles of a symbol, at the given period
            # 
            # Candels are used for OHLC representation
            # 
            # 
            # https://api.exchange.cryptomkt.com/#subscribe-to-candles
            # 
            # +String+ +symbol+:: A symbol to recieve a candle feed
            # +String+ period A valid tick interval. 'M1' (one minute), 'M3', 'M5', 'M15', 'M30', 'H1' (one hour), 'H4', 'D1' (one day), 'D7', '1M' (one month)
            # +Integer+ +limit+:: Optional. Maximum number of candles in the first feed. The rest of the feeds have one candle
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes one argument. recieves the candle feed
            # +Proc+ +resultCallback+:: Optional. A callable to call with the subscription result. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def subscribeToCandles(symbol, period, limit, callback, resultCallback=nil)
                params = {'symbol' => symbol, 'period' => period}
                sendSubscription('subscribeCandles', callback, params, resultCallback)
            end

            # Unsubscribe to the candles of a symbol at a given period
            # 
            # https://api.exchange.cryptomkt.com/#subscribe-to-candles
            # 
            # +String+ +symbol+:: The symbol of the candles
            # +String+ period 'M1' (one minute), 'M3', 'M5', 'M15', 'M30', 'H1' (one hour), 'H4', 'D1' (one day), 'D7', '1M' (one month)
            # +Proc+ +callback+:: Optional. A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def unsubscribeToCandles(symbol, period, callback=nil)
                sendUnsubscription('unsubscribeCandles', callback, {'symbol'=> symbol, 'period' => period})
            end
        end
    end
end