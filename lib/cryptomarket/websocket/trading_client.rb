# frozen_string_literal: true

# rubocop:disable Layout/LineLength
require_relative 'auth_client'
require_relative '../constants'

module Cryptomarket
  module Websocket
    # TradingClient connects via websocket to cryptomarket to enable the user to manage orders.
    # uses SHA256 as auth method and authenticates automatically after ceonnection.
    class TradingClient < AuthClient
      # Creates a new client
      # ==== Params
      # +string+ +api_key+:: the user api key
      # +string+ +api_secret+:: the user api secret
      # +Integer+ +window+:: Maximum difference between the creation of the request and the moment of request processing in milliseconds. Max is 60_000. Defaul is 10_000
      def initialize(api_key:, api_secret:, window: nil)
        super(
          url: 'wss://api.exchange.cryptomkt.com/api/3/ws/trading',
          api_key: api_key,
          api_secret: api_secret,
          window: window,
          subscription_keys: build_subscription_hash)
      end

      def build_subscription_hash
        reports = 'reports'
        balances = 'balances'
        { 'spot_subscribe' => [reports, Args::NotificationType::COMMAND],
          'spot_unsubscribe' => [reports, Args::NotificationType::COMMAND],
          'spot_orders' => [reports, Args::NotificationType::SNAPSHOT],
          'spot_order' => [reports, Args::NotificationType::UPDATE],
          'spot_balance_subscribe' => [balances, Args::NotificationType::COMMAND],
          'spot_balance_unsubscribe' => [balances, Args::NotificationType::COMMAND],
          'spot_balance' => [balances, Args::NotificationType::SNAPSHOT] }
      end

      alias get_spot_trading_balance_of_currency get_spot_trading_balance
      alias get_spot_trading_balance_by_currency get_spot_trading_balance
      alias get_spot_commission_of_symbol get_spot_commission
      alias get_spot_commission_by_symbol get_spot_commission

      # subscribe to a feed of execution reports of the user's orders
      #
      # https://api.exchange.cryptomkt.com/#socket-spot-trading
      #
      # ==== Params
      # +Proc+ +callback+:: A +Proc+ that recieves notifications as a list of reports, and the type of notification (either 'snapshot' or 'update')
      # +Proc+ +result_callback+:: Optional. A +Proc+ called with a boolean value, indicating the success of the subscription
      def subscribe_to_reports(callback:, result_callback: nil)
        interceptor = proc { |notification, type|
          if type == Args::NotificationType::SNAPSHOT
            callback.call(notification, type)
          else
            callback.call([notification], type)
          end
        }
        send_subscription('spot_subscribe', interceptor, {}, result_callback)
      end

      # stop recieveing the report feed subscription
      #
      # https://api.exchange.cryptomkt.com/#socket-spot-trading
      #
      # ==== Params
      # +Proc+ +callback+:: Optional. A +Proc+ called with a boolean value, indicating the success of the unsubscription
      def unsubscribe_to_reports(callback: nil)
        send_unsubscription('spot_unsubscribe', callback, nil)
      end

      # subscribe to a feed of the user's spot balances
      #
      # only non-zero values are present
      #
      # https://api.exchange.cryptomkt.com/#subscribe-to-spot-balances
      #
      # +Proc+ +callback+:: A +Proc+ that recieves notifications as a list of balances, the notification type is always data
      # +Proc+ +result_callback+:: Optional. A +Proc+ called with a boolean value, indicating the success of the subscription
      # +Proc+ +String+ +mode+:: Optional. The type of subscription, Either 'updates' or 'batches'. Update messages arrive after an update. Batch messages arrive at equal intervals after a first update
      def subscribe_to_spot_balance(callback:, mode: nil, result_callback: nil)
        interceptor = lambda { |notification, _type|
          callback.call(notification)
        }
        send_subscription('spot_balance_subscribe', interceptor, { mode: mode }, result_callback)
      end

      # stop recieving the feed of balances changes
      #
      # https://api.exchange.cryptomkt.com/#subscribe-to-wallet-balance
      #
      # ==== Params
      # +Proc+ +callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a boolean value indicating the success of the unsubscription
      def unsubscribe_to_spot_balance(result_callback: nil)
        send_unsubscription(
          'spot_balance_unsubscribe',
          result_callback,
          { mode: Args::SubscriptionMode::UPDATES }
        )
      end

      # Get the user's active spot orders
      #
      # https://api.exchange.cryptomkt.com/#get-active-spot-orders
      #
      # ==== Params
      # +Proc+ +callback+:: A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of reports for all active spot orders
      def get_active_spot_orders(callback:)
        request('spot_get_orders', callback)
      end

      # Creates a new spot order
      #
      # For fee, for price accuracy and quantity, and for order status information see the api docs at https://api.exchange.cryptomkt.com/#create-new-spot-order
      #
      # https://api.exchange.cryptomkt.com/#place-new-spot-order
      #
      # ==== Params
      # +String+ +symbol+:: Trading symbol
      # +String+ +side+:: Either 'buy' or 'sell'
      # +String+ +quantity+:: Order quantity
      # +String+ +client_order_id+:: Optional. If given must be unique within the trading day, including all active orders. If not given, is generated by the server
      # +String+ +type+:: Optional. 'limit', 'market', 'stopLimit', 'stopMarket', 'takeProfitLimit' or 'takeProfitMarket'. Default is 'limit'
      # +String+ +time_in_force+:: Optional. 'GTC', 'IOC', 'FOK', 'Day', 'GTD'. Default to 'GTC'
      # +String+ +price+:: Optional. Required for 'limit' and 'stopLimit'. limit price of the order
      # +String+ +stop_price+:: Optional. Required for 'stopLimit' and 'stopMarket' orders. stop price of the order
      # +String+ +expire_time+:: Optional. Required for orders with timeInForce = GDT
      # +Bool+ +strict_validate+:: Optional. If False, the server rounds half down for tickerSize and quantityIncrement. Example of ETHBTC: tickSize = '0.000001', then price '0.046016' is valid, '0.0460165' is invalid
      # +bool+ +post_only+:: Optional. If True, your post_only order causes a match with a pre-existing order as a taker, then the order will be cancelled
      # +String+ +take_rate+:: Optional. Liquidity taker fee, a fraction of order volume, such as 0.001 (for 0.1% fee). Can only increase the fee. Used for fee markup.
      # +String+ +make_rate+:: Optional. Liquidity provider fee, a fraction of order volume, such as 0.001 (for 0.1% fee). Can only increase the fee. Used for fee markup.
      # +Proc+ +callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, the report of the created order
      def create_spot_order( # rubocop:disable Metrics/ParameterLists
        symbol:, side:, quantity:, client_order_id: nil, type: nil, time_in_force: nil, price: nil, stop_price: nil,
        expire_time: nil, strict_validate: nil, post_only: nil, take_rate: nil, make_rate: nil, callback: nil
      )
        request('spot_new_order', callback,
                { client_order_id: client_order_id, symbol: symbol, side: side, quantity: quantity, type: type,
                  time_in_force: time_in_force, price: price, stop_price: stop_price, expire_time: expire_time,
                  strict_validate: strict_validate, post_only: post_only, take_rate: take_rate, make_rate: make_rate })
      end

      # creates a list of spot orders
      #
      # = Types or contingency
      # - 'allOrNone' (AON)
      # - 'oneCancelAnother' (OCO)
      # - 'oneTriggerOther' (OTO)
      # - 'oneTriggerOneCancelOther' (OTOCO)
      #
      # = Restriction in the number of orders:
      # - An AON list must have 2 or 3 orders
      # - An OCO list must have 2 or 3 orders
      # - An OTO list must have 2 or 3 orders
      # - An OTOCO must have 3 or 4 orders
      #
      # = Symbol restrictions
      # - For an AON order list, the symbol code of orders must be unique for each order in the list.
      # - For an OCO order list, there are no symbol code restrictions.
      # - For an OTO order list, there are no symbol code restrictions.
      # - For an OTOCO order list, the symbol code of orders must be the same for all orders in the list (placing orders in different order books is not supported).
      #
      # = OrderType restrictions
      # - For an AON order list, orders must be 'limit' or 'market'
      # - For an OCO order list, orders must be 'limit', 'stopLimit', 'stopMarket', takeProfitLimit or takeProfitMarket.
      # - An OCO order list cannot include more than one limit order (the same
      # applies to secondary orders in an OTOCO order list).
      # - For OTO order list, there are no order type restrictions.
      # - For an OTOCO order list, the first order must be 'limit', 'market', 'stopLimit', 'stopMarket', takeProfitLimit or takeProfitMarket.
      # - For an OTOCO order list, the secondary orders have the same restrictions as an OCO order
      # - Default is 'limit'
      #
      # https://api.exchange.cryptomkt.com/#create-new-spot-order-list
      #
      # ==== Params
      # +String+ +order_list_id+:: order list identifier. If ommited, it will be generated by the system. Must be equal to the client order id of the first order in the request
      # +String+ +contingency_type+:: order list type. 'allOrNone', 'oneCancelOther' or 'oneTriggerOneCancelOther'
      # +Array[]+ +orders+:: the list of orders. aech order in the list has the same parameters of a new spot order
      def create_spot_order_list(
        orders:, contingency_type:, order_list_id: nil, callback: nil
      )
        request('spot_new_order_list', callback, {
                  orders: orders, contingency_type: contingency_type, order_list_id: order_list_id
                },
                orders.count)
      end

      # cancels a spot order
      #
      # https://api.exchange.cryptomkt.com/#cancel-spot-order-2
      #
      # ==== Params
      # +String+ +client_order_id+:: the client order id of the order to cancel
      # +Proc+ +callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of reports of the canceled orders
      def cancel_spot_order(client_order_id:, callback: nil)
        request('spot_cancel_order', callback, { client_order_id: client_order_id })
      end

      # cancel all active spot orders and returns the ones that could not be canceled
      #
      # https://api.exchange.cryptomkt.com/#cancel-spot-orders
      #
      # ==== Params
      # +Proc+ +callback+:: A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a report of the canceled order
      def cancel_spot_orders(callback: nil)
        request('spot_cancel_orders', callback)
      end

      # Get the user's spot trading balance for all currencies with balance
      #
      # Requires the "Orderbook, History, Trading balance" API key Access Right
      #
      # https://api.exchange.cryptomkt.com/#get-spot-trading-balance
      #
      # ==== Params
      # +Proc+ +callback+:: A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of the trading balances
      def get_spot_trading_balances(callback:)
        request('spot_balances', callback)
      end

      # Get the user spot trading balance of a currency
      #
      # Requires the "Orderbook, History, Trading balance" API key Access Right
      #
      # https://api.exchange.cryptomkt.com/#get-spot-trading-balance
      #
      # ==== Params
      # +String+ +currency+:: The currency code to query the balance
      # +Proc+ +callback+:: A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a trading balance
      def get_spot_trading_balance(currency:, callback:)
        request('spot_balance', callback, { currency: currency })
      end

      # changes the parameters of an existing order, quantity or price
      #
      # https://api.exchange.cryptomkt.com/#cancel-replace-spot-order
      #
      # ==== Params
      # +String+ +client_order_id+:: the client order id of the order to change
      # +String+ +new_client_order_id+:: the new client order id for the modified order. must be unique within the trading day
      # +String+ +quantity+:: new order quantity
      # +String+ +price+:: new order price
      # +Bool+ +strict_validate+::  price and quantity will be checked for the incrementation with tick size and quantity step. See symbol's tick_size and quantity_increment
      # +Proc+ +callback+:: Optional. A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, the new version of the order
      def replace_spot_order( # rubocop:disable Metrics/ParameterLists
        client_order_id:, new_client_order_id:, quantity:, price:, strict_validate: nil, callback: nil
      )
        request('spot_replace_order', callback, {
                  client_order_id: client_order_id, new_client_order_id: new_client_order_id, quantity: quantity,
                  price: price, strict_validate: strict_validate
                })
      end

      # Get the personal trading commission rates for all symbols
      #
      # Requires the "Place/cancel orders" API key Access Right
      #
      # https://api.exchange.cryptomkt.com/#get-all-trading-commission
      #
      # ==== Params
      # +Proc+ +callback+:: A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a list of commissions for the user
      def get_spot_commissions(callback:)
        request('spot_fees', callback)
      end

      # Get the personal trading commission rate of a symbol
      #
      # Requires the "Place/cancel orders" API key Access Right
      #
      # https://api.exchange.cryptomkt.com/#get-trading-commission
      #
      # ==== Params
      # +String+ +symbol+:: The symbol of the commission rate
      # +Proc+ +callback+:: A +Proc+ of two arguments, An exception and a result, called either with the exception or with the result, a commission for a symbol for the user
      def get_spot_commission(symbol:, callback:)
        request('spot_fee', callback, { symbol: symbol })
      end
    end
  end
end
