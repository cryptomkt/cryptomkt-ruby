require "securerandom"

require_relative "wsClientBase"
require_relative "../constants"




module Cryptomarket
    module Websocket
        # MarketDataClient connects via websocket to cryptomarket to get market information of the exchange.

        class MarketDataClient < ClientBase

            def initialize()
                orderbook = "orderbook"
                tickers = "tickers"
                trades = "trades"
                candles = "candles"
                super(
                    url:"wss://api.exchange.cryptomkt.com/api/3/ws/public",
                    subscriptionKeys:{})
            end

            def sendChannelSubscription(channel, params={}, callback, resultCallback)
              if !params.nil?
                params = params.compact
              end
              payload = {'method'=>'subscribe', 'ch'=>channel, 'params'=>params}

              key = channel
              @callbackCache.storeSubscriptionCallback(key, callback)
              if not resultCallback.nil?
                id = @callbackCache.storeCallback(resultCallback)
                payload['id'] = id
              end
              @wsmanager.send(payload)
            end

            def handle(message)
              if message.has_key? 'ch'
                  handleChNotification(message)
              elsif message.has_key? 'id'
                  handleResponse(message)
              end
          end

            def handleChNotification(notification)
                key = notification['ch']
                callback = @callbackCache.getSubscriptionCallback(key)
                if callback.nil?
                  return
                end
                if notification.has_key? 'data'
                  callback.call(notification['data'], Args::NotificationType::DATA)
                end
                if notification.has_key? 'snapshot'
                  callback.call(notification['snapshot'], Args::NotificationType::SNAPSHOT)
                end
                if notification.has_key? 'update'
                  callback.call(notification['update'], Args::NotificationType::UPDATE)
                end
            end


            def intercept_result_callback(resultCallback)
              if resultCallback.nil?
                return resultCallback
              end
              return Proc.new {|err, result|
                if result.nil?
                  resultCallback.call(err, result)
                else
                  resultCallback.call(err, result['subscriptions'])
                end
              }
            end

            public

            # subscribe to a feed of trades
            #
            # subscription is for the specified symbols
            #
            # normal subscriptions have one update message per symbol
            #
            # the first notification contains the last n trades, with n defined by the
            # limit argument, the next notifications are updates and correspond to new trades
            #
            # Requires no API key Access Rights
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-trades
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of trades indexed by symbol, and the type of notification (either 'snapshot' or 'update')
            # +Array[String]+ +symbols+:: A list of symbol ids
            # +Integer+ +limit+:: Number of historical entries returned in the first feed. Min is 0. Max is 1000. Default is 0
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_trades(callback:, symbols:, limit:nil, resultCallback:nil)
              params = {'symbols'=>symbols, 'limit'=>limit}
              sendChannelSubscription('trades', params, callback, intercept_result_callback(resultCallback))
            end

            # subscribe to a feed of candles
            #
            # subscription is for the specified symbols
            #
            # normal subscriptions have one update message per symbol
            #
            # the first notification are n candles, with n defined by the limit argument,
            # the next notification are updates, with one candle at a time
            #
            # Requires no API key Access Rights
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-candles
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of candles indexed by symbol, and the type of notification (either 'snapshot' or 'update')
            # +String+ +period+:: Optional. A valid tick interval. 'M1' (one minute), 'M3', 'M5', 'M15', 'M30', 'H1' (one hour), 'H4', 'D1' (one day), 'D7', '1M' (one month). Default is 'M30'
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Integer+ +limit+:: Number of historical entries returned in the first feed. Min is 0. Max is 1000. Default is 0
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_candles(callback:, period:, symbols:, limit:nil, resultCallback:nil)
              params = {'symbols'=>symbols, 'limit'=>limit}
              sendChannelSubscription("candles/#{period}", params, callback, intercept_result_callback(resultCallback))
            end

            # subscribe to a feed of mini tickers
            #
            # subscription is for all symbols or for the specified symbols
            #
            # normal subscriptions have one update message per symbol
            #
            # Requires no API key Access Rights
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-mini-ticker
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of minitickers indexed by symbol, and the type of notification (only 'data')
            # +String+ +speed+:: The speed of the feed. '1s' or '3s'
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_mini_ticker(callback:, speed:, symbols:["*"], resultCallback:nil)
              params = {'symbols'=>symbols}
              sendChannelSubscription("ticker/price/#{speed}", params, callback, intercept_result_callback(resultCallback))
            end

            # subscribe to a feed of mini tickers
            #
            # subscription is for all symbols or for the specified symbols
            #
            # batch subscriptions have a joined update for all symbols
            #
            # Requires no API key Access Rights
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-mini-ticker-in-batches
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of minitickers indexed by symbol, and the type of notification (only 'data')
            # +String+ +speed+:: The speed of the feed. '1s' or '3s'
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_mini_ticker_in_batches(callback:, speed:, symbols:["*"], resultCallback:nil)
              params = {'symbols'=>symbols}
              sendChannelSubscription("ticker/price/#{speed}/batch", params, callback, intercept_result_callback(resultCallback))
            end

            # subscribe to a feed of tickers
            #
            # subscription is for all symbols or for the specified symbols
            #
            # normal subscriptions have one update message per symbol
            #
            # Requires no API key Access Rights
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-ticker
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of tickers indexed by symbol, and the type of notification (only 'data')
            # +String+ +speed+:: The speed of the feed. '1s' or '3s'
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_ticker(callback:, speed:, symbols:["*"], resultCallback:nil)
              params = {'symbols'=>symbols}
              sendChannelSubscription("ticker/#{speed}", params, callback, intercept_result_callback(resultCallback))
            end

            # subscribe to a feed of tickers
            #
            # subscription is for all symbols or for the specified symbols
            #
            # batch subscriptions have a joined update for all symbols
            #
            # Requires no API key Access Rights
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-ticker-in-batches
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of tickers indexed by symbol, and the type of notification (only 'data')
            # +String+ +speed+:: The speed of the feed. '1s' or '3s'
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_ticker_in_batches(callback:, speed:, symbols:["*"], resultCallback:nil)
              params = {'symbols'=>symbols}
              sendChannelSubscription("ticker/#{speed}/batch", params, callback, intercept_result_callback(resultCallback))
            end

            # subscribe to a feed of a full orderbook
            #
            # subscription is for the specified symbols
            #
            # normal subscriptions have one update message per symbol
            #
            # the first notification is a snapshot of the full orderbook, and next
            # notifications are updates to this snapshot
            #
            # Requires no API key Access Rights
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-full-order-book
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of full orderbooks indexed by symbol, and the type of notification (either 'snapshot' or 'update')
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_full_order_book(callback:, symbols:, resultCallback:nil)
              params = {'symbols'=>symbols}
              sendChannelSubscription("orderbook/full", params, callback, intercept_result_callback(resultCallback))
            end

            # subscribe to a feed of a partial orderbook
            #
            # subscription is for all symbols or for the specified symbols
            #
            # normal subscriptions have one update message per symbol
            #
            # Requires no API key Access Rights
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-partial-order-book
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of partial orderbooks indexed by symbol, and the type of notification (only 'data')
            # +String+ +speed+:: The speed of the feed. '100ms', '500ms' or '1000ms'
            # +String+ +depth+:: The depth of the partial orderbook
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_partial_order_book(callback:, depth:, speed:, symbols:["*"], resultCallback:nil)
              params = {'symbols'=>symbols}
              sendChannelSubscription("orderbook/#{depth}/#{speed}", params, callback, intercept_result_callback(resultCallback))
            end

            # subscribe to a feed of a partial orderbook in batches
            #
            # subscription is for all symbols or for the specified symbols
            #
            # batch subscriptions have a joined update for all symbols
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-partial-order-book-in-batches
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of partial orderbooks indexed by symbol, and the type of notification (only 'data')
            # +String+ +speed+:: The speed of the feed. '100ms', '500ms' or '1000ms'
            # +String+ +depth+:: The depth of the partial orderbook
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_partial_order_book_in_batches(callback:, depth:, speed:, symbols:["*"], resultCallback:nil)
              params = {'symbols'=>symbols}
              sendChannelSubscription("orderbook/#{depth}/#{speed}/batch", params, callback, intercept_result_callback(resultCallback))
            end


            # subscribe to a feed of the top of the orderbook
            #
            # subscription is for all symbols or for the specified symbols
            #
            # normal subscriptions have one update message per symbol
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-top-of-book
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of top of orderbooks indexed by symbol, and the type of notification (only 'data')
            # +String+ +speed+:: The speed of the feed. '100ms', '500ms' or '1000ms'
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_top_of_book(callback:, speed:, symbols:["*"], resultCallback:nil)
              params = {'symbols'=>symbols}
              sendChannelSubscription("orderbook/top/#{speed}", params, callback, intercept_result_callback(resultCallback))
            end


            # subscribe to a feed of the top of the orderbook
            #
            # subscription is for all symbols or for the specified symbols
            #
            # batch subscriptions have a joined update for all symbols
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-top-of-book-in-batches
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of top of orderbooks indexed by symbol, and the type of notification (only 'data')
            # +String+ +speed+:: The speed of the feed. '100ms', '500ms' or '1000ms'
            # +Array[String]+ +symbols+:: Optional. A list of symbol ids
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a list of subscribed symbols

            def subscribe_to_top_of_book_in_batches(callback:, speed:, symbols:["*"], resultCallback:nil)
              params = {'symbols'=>symbols}
              sendChannelSubscription("orderbook/top/#{speed}/batch", params, callback, intercept_result_callback(resultCallback))
            end
        end
    end
end