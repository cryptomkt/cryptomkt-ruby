# frozen_string_literal: true

# rubocop:disable Layout/LineLength
require 'securerandom'

require_relative 'market_data_client_core'
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
      # +Integer+ +limit+:: Number of historical entries returned in the first feed. Min is 0. Max is 1_000. Default is 0
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_trades(callback:, symbols:, limit: nil, result_callback: nil)
        params = { 'symbols' => symbols, 'limit' => limit }
        send_channel_subscription('trades', callback, intercept_result_callback(result_callback), params)
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
      # +Integer+ +limit+:: Number of historical entries returned in the first feed. Min is 0. Max is 1_000. Default is 0
      # +Proc+ +result_callback+:: Optional. A +Proc+ called with a list of subscribed symbols

      def subscribe_to_candles(callback:, period:, symbols:, limit: nil, result_callback: nil)
        params = { 'symbols' => symbols, 'limit' => limit }
        send_channel_subscription("candles/#{period}", callback,
                                  intercept_result_callback(result_callback), params)
      end

      # Gets OHLCV data regarding the last price converted to the target currency for all symbols or for the specified symbols
      #
      # Candles are used for the representation of a specific symbol as an OHLC chart
      #
      #  Conversion from the symbol quote currency to the target currency is the mean of "best" bid price and "best" ask price in the order book. If there is no "best" bid of ask price, the last price is returned.
      #
      # Requires no API key Access Rights
      #
      # https://api.exchange.cryptomkt.com/#candles
      #
      # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of candles indexed by symbol, and the type of notification (either 'snapshot' or 'update')
      # +String+ +target_currency+:: Target currency for conversion
      # +Array[String]+ +symbols+:: Optional. A list of symbols
      # +String+ +period+:: A valid tick interval. 'M1' (one minute), 'M3', 'M5', 'M15', 'M30', 'H1' (one hour), 'H4', 'D1' (one day), 'D7', '1M' (one month). Default is 'M30'
      # +String+ +from+:: Optional. Initial value of the queried interval. As DateTime
      # +String+ +till+:: Optional. Last value of the queried interval. As DateTime
      # +Integer+ +limit+:: Optional. Prices per currency pair. Defaul is 100. Min is 1. Max is 1_000
      # +Proc+ +result_callback+:: Optional. A +Proc+ called with a list of subscribed symbols

      def subscribe_to_converted_candles(callback:, target_currency:, symbols:, period:, limit: nil, result_callback: nil) # rubocop:disable Metrics/ParameterLists
        params = { 'target_currency' => target_currency, 'symbols' => symbols, 'limit' => limit }
        send_channel_subscription("converted/candles/#{period}", callback,
                                  intercept_result_callback(result_callback), params)
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
        send_channel_subscription("ticker/price/#{speed}", callback,
                                  intercept_result_callback(result_callback), params)
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
        send_channel_subscription("ticker/price/#{speed}/batch", callback,
                                  intercept_result_callback(result_callback), params)
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
        send_channel_subscription("ticker/#{speed}", callback, intercept_result_callback(result_callback), params)
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
        send_channel_subscription("ticker/#{speed}/batch", callback, intercept_result_callback(result_callback), params)
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
        send_channel_subscription('orderbook/full', callback, intercept_result_callback(result_callback), params)
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
        send_channel_subscription("orderbook/#{depth}/#{speed}", callback,
                                  intercept_result_callback(result_callback), params)
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
        send_channel_subscription("orderbook/#{depth}/#{speed}/batch", callback,
                                  intercept_result_callback(result_callback), params)
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
        send_channel_subscription("orderbook/top/#{speed}", callback,
                                  intercept_result_callback(result_callback), params)
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
        send_channel_subscription("orderbook/top/#{speed}/batch", callback,
                                  intercept_result_callback(result_callback), params)
      end

      # subscribe to a feed of the top of the orderbook
      #
      # subscription is for all currencies or for the specified currencies
      #
      # https://api.exchange.cryptomkt.com/#subscribe-to-price-rates
      #
      # ==== Params
      # +Proc+ +callback+:: A +Proc+ that recieves notifications as a hash of top of orderbooks indexed by symbol, and the type of notification (only 'data')
      # +String+ +speed+:: The speed of the feed. '1s' or '3s'
      # +String+ +target_currency+:: Quote currency of the rate
      # +Array[String]+ +currencies+:: Optional. A list of currencies ids
      # +Proc+ +result_callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of subscribed symbols

      def subscribe_to_price_rates(callback:, speed:, target_currency:, currencies: ['*'], result_callback: nil)
        params = {
          speed: speed, target_currency: target_currency, currencies: currencies
        }
        send_channel_subscription("price/rate/#{speed}", callback, intercept_result_callback(result_callback), params)
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
          speed: speed, target_currency: target_currency, currencies: currencies
        }
        send_channel_subscription("price/rate/#{speed}/batch", callback,
                                  intercept_result_callback(result_callback), params)
      end
    end
  end
end
