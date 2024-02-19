require 'securerandom'

require_relative 'marketDataClientCore'
require_relative '../constants'

module Cryptomarket
  module Websocket
    # MarketDataClient connects via websocket to cryptomarket to get market information of the exchange.
    class MarketDataClient < MarketDataClientCore
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_trades(callback:, symbols:, limit: nil, result_callback: nil)
        params = { 'symbols' => symbols, 'limit' => limit }
        send_channel_subscription('trades', params, callback, intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ called with a list of subscribed symbols

      def subscribe_to_candles(callback:, period:, symbols:, limit: nil, result_callback: nil)
        params = { 'symbols' => symbols, 'limit' => limit }
        send_channel_subscription("candles/#{period}", params, callback,
                                  intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_mini_ticker(callback:, speed:, symbols: ['*'], result_callback: nil)
        params = { 'symbols' => symbols }
        send_channel_subscription("ticker/price/#{speed}", params, callback,
                                  intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_mini_ticker_in_batches(callback:, speed:, symbols: ['*'], result_callback: nil)
        params = { 'symbols' => symbols }
        send_channel_subscription("ticker/price/#{speed}/batch", params, callback,
                                  intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_ticker(callback:, speed:, symbols: ['*'], result_callback: nil)
        params = { 'symbols' => symbols }
        send_channel_subscription("ticker/#{speed}", params, callback, intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_ticker_in_batches(callback:, speed:, symbols: ['*'], result_callback: nil)
        params = { 'symbols' => symbols }
        send_channel_subscription("ticker/#{speed}/batch", params, callback,
                                  intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_full_order_book(callback:, symbols:, result_callback: nil)
        params = { 'symbols' => symbols }
        send_channel_subscription('orderbook/full', params, callback, intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_partial_order_book(callback:, depth:, speed:, symbols: ['*'], result_callback: nil)
        params = { 'symbols' => symbols }
        send_channel_subscription("orderbook/#{depth}/#{speed}", params, callback,
                                  intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_partial_order_book_in_batches(callback:, depth:, speed:, symbols: ['*'],
                                                     result_callback: nil)
        params = { 'symbols' => symbols }
        send_channel_subscription("orderbook/#{depth}/#{speed}/batch", params, callback,
                                  intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_top_of_book(callback:, speed:, symbols: ['*'], result_callback: nil)
        params = { 'symbols' => symbols }
        send_channel_subscription("orderbook/top/#{speed}", params, callback,
                                  intercept_result_callback(result_callback))
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
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_top_of_book_in_batches(callback:, speed:, symbols: ['*'], result_callback: nil)
        params = { 'symbols' => symbols }
        send_channel_subscription("orderbook/top/#{speed}/batch", params, callback,
                                  intercept_result_callback(result_callback))
      end

      # subscribe to a feed of the top of the orderbook
      #
      # subscription is for all currencies or for the specified currencies
      #
      # https://api.exchange.cryptomkt.com/#subscribe-to-top-of-book-in-batches
      #
      # ==== Params
      # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of top of orderbooks indexed by symbol, and the type of notification (only 'data')
      # +String+ +speed+:: The speed of the feed. '1s' or '3s'
      # +String+ +target_currency+:: Quote currency of the rate
      # +Array[String]+ +currencies+:: Optional. A list of currencies ids
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_price_rates(callback:, speed:, target_currency:, currencies: ['*'], result_callback: nil)
        params = {
          speed: speed,
          target_currency: target_currency,
          currencies: currencies
        }
        send_channel_subscription("price/rate/#{speed}", params, callback,
                                  intercept_result_callback(result_callback))
      end

      # subscribe to a feed of the top of the orderbook
      #
      # subscription is for all currencies or for the specified currencies
      #
      # batch subscriptions have a joined update for all currencies
      #
      # https://api.exchange.cryptomkt.com/#subscribe-to-price-rates-in-batches
      #
      # ==== Params
      # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of top of orderbooks indexed by symbol, and the type of notification (only 'data')
      # +String+ +speed+:: The speed of the feed. '1s' or '3s'
      # +String+ +target_currency+:: Quote currency of the rate
      # +Array[String]+ +currencies+:: Optional. A list of currencies ids
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_price_rates_in_batches(callback:, speed:, target_currency:, currencies: ['*'],
                                              result_callback: nil)
        params = {
          speed: speed,
          target_currency: target_currency,
          currencies: currencies
        }
        send_channel_subscription("price/rate/#{speed}/batch", params, callback,
                                  intercept_result_callback(result_callback))
      end
    end
  end
end
