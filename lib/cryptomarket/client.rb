require_relative "http_manager"

module Cryptomarket
  # Creates a new rest client
  #
  # ==== Params
  # +String+ +apiKey+:: the user api key
  # +String+ +apiSecret+:: the user api secret
  # +Integer+ +window+:: Maximum difference between the creation of the request and the moment of request processing in milliseconds. Max is 60_000. Defaul is 10_000

  class Client

    def initialize(apiKey:nil, apiSecret:nil, window:nil)
      @httpManager = HttpManager.new apiKey:apiKey, apiSecret:apiSecret, window:window
    end

    def public_get(endpoint, params=nil)
      return @httpManager.makeRequest(method:'get', endpoint:endpoint, params:params, public: true)
    end

    def get(endpoint, params=nil)
      return @httpManager.makeRequest(method:'get', endpoint:endpoint, params:params)
    end

    def post(endpoint, params=nil)
      return @httpManager.makeRequest(method:'post', endpoint:endpoint, params:params)
    end

    def put(endpoint, params=nil)
      return @httpManager.makeRequest(method:'put', endpoint:endpoint, params:params)
    end

    def patch(endpoint, params=nil)
      return @httpManager.makeRequest(method:'patch', endpoint:endpoint, params:params)
    end

    def delete(endpoint, params=nil)
        return @httpManager.makeRequest(method:'delete', endpoint:endpoint, params:params)
    end


    ################
    # public calls #
    ################

    # Get a Hash of all currencies or specified currencies. indexed by id
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#currencies
    #
    # ==== Params
    # +Array[String]+ +currencies+:: Optional. A list of currencies ids

    def get_currencies(currencies:nil)
      return public_get('public/currency/', {currencies:currencies})
    end

    # Get the data of a currency
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#currencies
    #
    # ==== Params
    # +String+ +currency+:: A currency id

    def get_currency(currency:)
      return public_get("public/currency/#{currency}")
    end

    # Get a Hash of all symbols or for specified symbols. indexed by id
    # A symbol is the combination of the base currency (first one) and quote currency (second one)
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#symbols
    #
    # ==== Params
    # +Array[String]+ +symbols+:: Optional. A list of symbol ids

    def get_symbols (symbols:nil)
      return public_get("public/symbol", {symbols:symbols})
    end

    # Get a symbol by its id
    # A symbol is the combination of the base currency (first one) and quote currency (second one)
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#symbols
    #
    # ==== Params
    # +String+ +symbol+:: A symbol id

    def get_symbol(symbol:)
      return public_get("public/symbol/#{symbol}")
    end

    # Get a Hash of tickers for all symbols or for specified symbols. indexed by symbol
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#tickers
    #
    # ==== Params
    # +Array[String]+ +symbols+:: Optional. A list of symbol ids

    def get_tickers(symbols:nil)
      return public_get("public/ticker", {symbols:symbols})
    end

    # Get the ticker of a symbol
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#tickers
    #
    # ==== Params
    # +String+ +symbol+:: A symbol id

    def get_ticker(symbol:)
      return public_get("public/ticker/#{symbol}")
    end


    # Get a Hash of quotation prices of currencies
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#prices
    #
    # ==== Params
    # +String+ +to+:: Target currency code
    # +String+ +from+:: Optional. Source currency rate

    def get_prices(to:, from:nil)
      return public_get("public/price/rate", {to:to, from:from})
    end


    # Get quotation prices history
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#prices
    #
    # ==== Params
    # +String+ +to+:: Target currency code
    # +String+ +from+:: Optional. Source currency rate
    # +String+ +period+:: Optional. A valid tick interval. 'M1' (one minute), 'M3', 'M5', 'M15', 'M30', 'H1' (one hour), 'H4', 'D1' (one day), 'D7', '1M' (one month). Default is 'M30'
    # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
    # +String+ +since+:: Optional. Initial value of the queried interval
    # +String+ +until+:: Optional. Last value of the queried interval
    # +Integer+ +limit+:: Optional. Prices per currency pair. Defaul is 1. Min is 1. Max is 1000

    def get_price_history(to:, from:nil, till:nil, since:nil, limit:nil, period:nil, sort:nil)
      return public_get(
        "public/price/history",
        {
          to:to,
          from:from,
          till:till,
          since:since,
          limit:limit,
          period:period,
          sort:sort
        }
      )
    end


    # Get a Hash of the ticker's last prices for all symbols or for the specified symbols
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#prices
    #
    # ==== Params
    # +Array[String]+ +symbols+:: Optional. A list of symbol ids

    def get_ticker_prices(symbols:nil)
      return public_get("public/price/ticker", {symbols:symbols})
    end


    # Get ticker's last prices of a symbol
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#prices
    #
    # ==== Params
    # +String+ +symbol+:: A symbol id

    def get_ticker_price_of_symbol(symbol:)
      return public_get("public/price/ticker/#{symbol}")
    end

    # Get a Hash of trades for all symbols or for specified symbols
    # 'from' param and 'till' param must have the same format, both id or both timestamp
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#trades
    #
    # ==== Params
    # +Array[String]+ +symbols+:: Optional. A list of symbol ids
    # +String+ +by+:: Optional. Sorting parameter. 'id' or 'timestamp'. Default is 'timestamp'
    # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
    # +String+ +since+:: Optional. Initial value of the queried interval
    # +String+ +until+:: Optional. Last value of the queried interval
    # +Integer+ +limit+:: Optional. Prices per currency pair. Defaul is 10. Min is 1. Max is 1000

    def get_trades(symbols:nil, by:nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil)
      return public_get(
        "public/trades/",
        {
          symbols:symbols,
          by:by,
          sort:sort,
          from:from,
          till:till,
          limit:limit,
          offset:offset
        }
      )
    end


    # Get trades of a symbol
    # 'from' param and 'till' param must have the same format, both id or both timestamp
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#trades
    #
    # ==== Params
    # +String+ +symbol+:: A symbol id
    # +String+ +by+:: Optional. Sorting parameter. 'id' or 'timestamp'. Default is 'timestamp'
    # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
    # +String+ +since+:: Optional. Initial value of the queried interval
    # +String+ +until+:: Optional. Last value of the queried interval
    # +Integer+ +limit+:: Optional. Prices per currency pair. Defaul is 10. Min is 1. Max is 1000
    # +Integer+ +offset+:: Optional. Default is 0. Min is 0. Max is 100000

    def get_trades_of_symbol(symbol:nil, by:nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil)
      return public_get(
        "public/trades/#{symbol}",
        {
          by:by,
          sort:sort,
          from:from,
          till:till,
          limit:limit,
          offset:offset
        }
      )
    end


    # Get a Hash of orderbooks for all symbols or for the specified symbols
    # An Order Book is an electronic list of buy and sell orders for a specific symbol, structured by price level
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#order-books
    #
    # ==== Params
    # +Array[String]+ +symbols+:: Optional. A list of symbol ids
    # +Integer+ +depth+:: Optional. Order Book depth. Default value is 100. Set to 0 to view the full Order Book

    def get_orderbooks(symbols:nil, depth:nil)
      return public_get("public/orderbook", {symbols:symbols, depth:depth})
    end



    # Get order book of a symbol
    # An Order Book is an electronic list of buy and sell orders for a specific symbol, structured by price level
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#order-books
    #
    # ==== Params
    # +String+ +symbol+:: A symbol id
    # +Integer+ +depth+:: Optional. Order Book depth. Default value is 100. Set to 0 to view the full Order Book

    def get_orderbook_of_symbol(symbol:, depth:nil)
      return public_get("public/orderbook/#{symbol}", {depth:depth})
    end



    # Get order book of a symbol with the desired volume for market depth search
    # An Order Book is an electronic list of buy and sell orders for a specific symbol, structured by price level
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#order-books
    #
    # ==== Params
    # +String+ +symbol+:: A symbol id
    # +float+ +volume+:: Optional. Desired volume for market depth search

    def get_orderbook_volume_of_symbol(symbol:, volume:nil)
      return public_get("public/orderbook/#{symbol}", {volume:volume})
    end

    # Get a Hash of candles for all symbols or for specified symbols
    # Candels are used for OHLC representation
    # The result contains candles with non-zero volume only (no trades = no candles)
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#candles
    #
    # ==== Params
    # +String+ +symbol+:: A symbol id
    # +String+ +period+:: Optional. A valid tick interval. 'M1' (one minute), 'M3', 'M5', 'M15', 'M30', 'H1' (one hour), 'H4', 'D1' (one day), 'D7', '1M' (one month). Default is 'M30'
    # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
    # +String+ +from+:: Optional. Initial value of the queried interval. As DateTime
    # +String+ +till+:: Optional. Last value of the queried interval. As DateTime
    # +Integer+ +limit+:: Optional. Prices per currency pair. Defaul is 10. Min is 1. Max is 1000

    def get_candles(symbols:nil, period:nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil)
      return public_get(
        "public/candles/",
        {
          symbols:symbols,
          period:period,
          sort:sort,
          from:from,
          till:till,
          limit:limit,
          offset:offset
        }
      )
    end

    # Get candles of a symbol
    # Candels are used for OHLC representation
    # The result contains candles with non-zero volume only (no trades = no candles)
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#candles
    #
    # ==== Params
    # +String+ +symbol+:: A symbol id
    # +String+ +period+:: Optional. A valid tick interval. 'M1' (one minute), 'M3', 'M5', 'M15', 'M30', 'H1' (one hour), 'H4', 'D1' (one day), 'D7', '1M' (one month). Default is 'M30'
    # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
    # +String+ +from+:: Optional. Initial value of the queried interval. As DateTime
    # +String+ +till+:: Optional. Last value of the queried interval. As DateTime
    # +Integer+ +limit+:: Optional. Prices per currency pair. Defaul is 100. Min is 1. Max is 1000
    # +Integer+ +offset+:: Optional. Default is 0. Min is 0. Max is 100000

    def get_candles_of_symbol(symbol:, period:nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil)
      return public_get(
        "public/candles/#{symbol}",
        {
          period:period,
          sort:sort,
          from:from,
          till:till,
          limit:limit,
          offset:offset
        }
      )
    end

    ######################
    # Spot Trading calls #
    ######################

    # Get the user's spot trading balance for all currencies with balance
    #
    # Requires the "Orderbook, History, Trading balance" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-spot-trading-balance

    def get_spot_trading_balance
      return get("spot/balance")
    end

    # Get the user spot trading balance of a currency
    #
    # Requires the "Orderbook, History, Trading balance" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-spot-trading-balance
    #
    # ==== Params
    # +String+ +currency+:: The currency code to query the balance

    def get_spot_trading_balance_of_currency(currency:)
      balance = get("spot/balance/#{currency}")
      balance["currency"] = currency
      return balance
    end



    # Get the user's active spot orders
    #
    # Requires the "Place/cancel orders" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-all-active-spot-orders
    #
    # ==== Params
    # +String+ +symbol+:: Optional. A symbol for filtering the active spot orders

    def get_all_active_spot_orders(symbol:nil)
      return get("spot/order", {symbol:symbol})
    end

    # Get an active spot order by its client order id
    #
    # Requires the "Place/cancel orders" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-active-spot-orders
    #
    # ==== Params
    # +String+ +client_order_id+:: The client order id of the order

    def get_active_spot_order(client_order_id:)
      return get("spot/order/#{client_order_id}")
    end

    # Creates a new spot order
    # For fee, for price accuracy and quantity, and for order status information see the api docs
    #
    # Requires the "Place/cancel orders" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#create-new-spot-order
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
    # +bool+ +strict_validate+:: Optional. If False, the server rounds half down for tickerSize and quantityIncrement. Example of ETHBTC: tickSize = '0.000001', then price '0.046016' is valid, '0.0460165' is invalid
    # +bool+ +post_only+:: Optional. If True, your post_only order causes a match with a pre-existing order as a taker, then the order will be cancelled
    # +String+ +take_rate+:: Optional. Liquidity taker fee, a fraction of order volume, such as 0.001 (for 0.1% fee). Can only increase the fee. Used for fee markup.
    # +String+ +make_rate+:: Optional. Liquidity provider fee, a fraction of order volume, such as 0.001 (for 0.1% fee). Can only increase the fee. Used for fee markup.

    def create_spot_order(
      symbol:,
      side:,
      quantity:,
      client_order_id:nil,
      type:nil,
      time_in_force:nil,
      price:nil,
      stop_price:nil,
      expire_time:nil,
      strict_validate:nil,
      post_only:nil,
      take_rate:nil,
      make_rate:nil
    )
      return post(
        "spot/order",
        {
          client_order_id:client_order_id,
          symbol:symbol,
          side:side,
          quantity:quantity,
          type:type,
          time_in_force:time_in_force,
          price:price,
          stop_price:stop_price,
          expire_time:expire_time,
          strict_validate:strict_validate,
          post_only:post_only,
          take_rate:take_rate,
          make_rate:make_rate
        }
      )
    end

    # creates a list of spot orders
    #
    # = Types or contingency
    # - Contingency.ALL_OR_NONE (Contingency.AON)
    # - Contingency.ONE_CANCEL_OTHER (Contingency.OCO)
    # - Contingency.ONE_TRIGGER_ONE_CANCEL_OTHER (Contingency.OTOCO)
    #
    # = Restriction in the number of orders:
    # - An AON list must have 2 or 3 orders
    # - An OCO list must have 2 or 3 orders
    # - An OTOCO must have 3 or 4 orders
    #
    # = Symbol restrictions
    # - For an AON order list, the symbol code of orders must be unique for each order in the list.
    # - For an OCO order list, there are no symbol code restrictions.
    # - For an OTOCO order list, the symbol code of orders must be the same for all orders in the list (placing orders in different order books is not supported).
    #
    # = OrderType restrictions
    # - For an AON order list, orders must be OrderType.LIMIT or OrderType.Market
    # - For an OCO order list, orders must be OrderType.LIMIT, OrderType.STOP_LIMIT, OrderType.STOP_MARKET, OrderType.TAKE_PROFIT_LIMIT or OrderType.TAKE_PROFIT_MARKET.
    # - An OCO order list cannot include more than one limit order (the same
    # applies to secondary orders in an OTOCO order list).
    # - For an OTOCO order list, the first order must be OrderType.LIMIT, OrderType.MARKET, OrderType.STOP_LIMIT, OrderType.STOP_MARKET, OrderType.TAKE_PROFIT_LIMIT or OrderType.TAKE_PROFIT_MARKET.
    # - For an OTOCO order list, the secondary orders have the same restrictions as an OCO order
    # - Default is OrderType.Limit
    #
    # https://api.exchange.cryptomkt.com/#create-new-spot-order-list-2
    #
    # ==== Params
    # +String+ +order_list_id+:: order list identifier. If ommited, it will be generated by the system. Must be equal to the client order id of the first order in the request
    # +String+ +contingency_type+:: order list type. allOrNone, oneCancelOther or oneTriggerOneCancelOther
    # +Array[]+ +orders+:: the list of orders

    def create_spot_order_list(
      contingency_type:,
      order_list_id:nil,
      orders:,
    )
      return post(
        "spot/order/list",
        {
          order_list_id: order_list_id,
          contingency_type: contingency_type,
          orders: orders,
        }
      )
    end

    # Replaces a spot order
    # For fee, for price accuracy and quantity, and for order status information see the api docs
    #
    # Requires the "Place/cancel orders" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#replace-spot-order
    #
    # ==== Params
    # +String+ +client_order_id+:: client order id of the old order
    # +String+ +new client order id+:: client order id for the new order
    # +String+ +quantity+:: Order quantity
    # +bool+ +strict_validate+:: Price and quantity will be checked for incrementation within the symbol’s tick size and quantity step. See the symbol's tick_size and quantity_increment
    # +String+ +price+:: Required if order type is 'limit', 'stopLimit', or 'takeProfitLimit'. Order price

    def replace_spot_order(
      client_order_id:,
      new_client_order_id:,
      quantity:,
      price:nil,
      strict_validate:nil
    )
      return patch(
        "spot/order/#{client_order_id}",
        {
          new_client_order_id:new_client_order_id,
          price:price,
          quantity:quantity,
          strict_validate:strict_validate
        }
      )
    end

    # Cancel all active spot orders
    #
    # Requires the "Place/cancel orders" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#cancel-all-spot-orders
    #

    def cancel_all_spot_orders
      return delete("spot/order")
    end

    # Cancel the order with the client order id
    #
    # Requires the "Place/cancel orders" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#cancel-spot-order
    #
    # ==== Params
    # +String+ +client_order_id+:: client order id of the order to cancel

    def cancel_spot_order(client_order_id:)
      delete("spot/order/#{client_order_id}")
    end

    # Get the personal trading commission rates for all symbols
    #
    # Requires the "Place/cancel orders" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-all-trading-commission

    def get_all_trading_commission
      get("spot/fee")
    end

    # Get the personal trading commission rate of a symbol
    #
    # Requires the "Place/cancel orders" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-trading-commission
    #
    # ==== Params
    # +String+ +symbol+:: The symbol of the commission rate

    def get_trading_commission(symbol:)
      commission = get("spot/fee/#{symbol}")
      commission["symbol"] = symbol
      return commission
    end

    ########################
    # spot trading history #
    ########################

    # Get all the spot orders
    # Orders without executions are deleted after 24 hours
    # 'from' param and 'till' param must have the same format, both id or both timestamp
    #
    # Requires the "Orderbook, History, Trading balance" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#spot-orders-history
    #
    # ==== Params
    # +String+ +symbol+:: Optional. Filter orders by symbol
    # +String+ +by+:: Optional. Sorting parameter. 'id' or 'timestamp'. Default is 'timestamp'
    # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
    # +String+ +from+:: Optional. Initial value of the queried interval
    # +String+ +till+:: Optional. Last value of the queried interval
    # +Integer+ +limit+:: Optional. Prices per currency pair. Defaul is 100. Max is 1000
    # +Integer+ +offset+:: Optional. Default is 0. Max is 100000

    def get_spot_orders_history(
      client_order_id:nil,
      symbol:nil,
      sort:nil,
      by:nil,
      from:nil,
      till:nil,
      limit:nil,
      offset:nil
    )
      return get(
        "spot/history/order",
        {
          client_order_id:client_order_id,
          symbol:symbol,
          sort:sort,
          by:by,
          from:from,
          till:till,
          limit:limit,
          offset:offset
        }
      )
    end

    # Get the user's spot trading history
    #
    # Requires the "Orderbook, History, Trading balance" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#spot-trades-history
    #
    # ==== Params
    # +String+ +order id+:: Optional. Order unique identifier as assigned by the exchange
    # +String+ +symbol+:: Optional. Filter orders by symbol
    # +String+ +by+:: Optional. Sorting parameter. 'id' or 'timestamp'. Default is 'timestamp'
    # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
    # +String+ +from+:: Optional. Initial value of the queried interval
    # +String+ +till+:: Optional. Last value of the queried interval
    # +Integer+ +limit+:: Optional. Prices per currency pair. Defaul is 100. Max is 1000
    # +Integer+ +offset+:: Optional. Default is 0. Max is 100000

    def get_spot_trades_history(
      order_id:nil,
      symbol:nil,
      sort:nil,
      by:nil,
      from:nil,
      till:nil,
      limit:nil,
      offset:nil
    )
      return get(
        "spot/history/trade",
        {
          order_id:order_id,
          symbol:symbol,
          sort:sort,
          by:by,
          from:from,
          till:till,
          limit:limit,
          offset:offset
        }
      )
    end

    #####################
    # Wallet Management #
    #####################

    # Get the user's wallet balance for all currencies with balance
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#wallet-balance

    def get_wallet_balance
      return get("wallet/balance")
    end

    # Get the user's wallet balance of a currency
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#wallet-balance
    #
    # ==== Params
    # +String+ +currency+:: The currency code to query the balance

    def get_wallet_balance_of_currency(currency:)
      return get("wallet/balance/#{currency}")
    end

    # Get a list with the current addresses of the user
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#deposit-crypto-address

    def get_deposit_crypto_addresses()
      return get("wallet/crypto/address")
    end


    # Get the current addresses of a currency of the user
    #
    # Getting the address of a new currency will create an address
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#deposit-crypto-address
    #
    # ==== Params
    # +String+ +currency+:: Currency to get the address

    def get_deposit_crypto_address_of_currency(currency:nil)
      result = get("wallet/crypto/address", {currency:currency})
      if result.length != 1
        raise CryptomarketSDKException "Too many currencies recieved, expected 1 currency"
      end
      return result[0]
    end


    # Creates a new address for a currency
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#deposit-crypto-address
    #
    # ==== Params
    # +String+ +currency+:: currency to create a new address

    def create_deposit_crypto_address(currency:)
      return post("wallet/crypto/address", {currency:currency})
    end

    # Get the last 10 unique addresses used for deposit, by currency
    # Addresses used a long time ago may be omitted, even if they are among the last 10 unique addresses
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#last-10-deposit-crypto-address
    #
    # ==== Params
    # +String+ +currency+:: currency to get the list of addresses

    def get_last_10_deposit_crypto_addresses(currency:)
      return get("wallet/crypto/address/recent-deposit", {currency:currency})
    end

    # Get the last 10 unique addresses used for withdrawals, by currency
    # Addresses used a long time ago may be omitted, even if they are among the last 10 unique addresses
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#last-10-withdrawal-crypto-addresses
    #
    # ==== Params
    # +String+ +currency+:: currency to get the list of addresses

    def get_last_10_withdrawal_crypto_addresses(currency:)
      return get("wallet/crypto/address/recent-withdraw", {currency:currency})
    end

    # Please take note that changing security settings affects withdrawals:
    # - It is impossible to withdraw funds without enabling the two-factor authentication (2FA)
    # - Password reset blocks withdrawals for 72 hours
    # - Each time a new address is added to the whitelist, it takes 48 hours before that address becomes active for withdrawal
    # Successful response to the request does not necessarily mean the resulting transaction got executed immediately. It has to be processed first and may eventually be rolled back
    # To see whether a transaction has been finalized, call #get_transaction
    #
    # Requires the "Withdraw cryptocurrencies" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#withdraw-crypto
    #
    # ==== Params
    # +String+ +currency+:: currency code of the crypto to withdraw
    # +float+ +amount+:: amount to be sent to the specified address
    # +String+ +address+:: address identifier
    # +String+ +payment id+:: Optional.
    # +bool+ +include fee+:: Optional. If true then the amount includes fees. Default is false
    # +bool+ +auto commit+:: Optional. If false then you should commit or rollback the transaction in an hour. Used in two phase commit schema. Default is true
    # +String+ +use offchain+:: Optional. Whether the withdrawal may be comitted offchain. Accepted values are 'never', 'optionaly' and 'required'. Default is TODO
    # +String+ +public comment+:: Optional. Maximum lenght is 255

    def withdraw_crypto(
      currency:,
      amount:,
      address:,
      payment_id:nil,
      include_fee:nil,
      auto_commit:nil,
      use_offchain:nil,
      public_comment:nil
    )
      return post(
        "wallet/crypto/withdraw",
        {
          currency:currency,
          amount:amount,
          address:address,
          payment_id:payment_id,
          include_fee:include_fee,
          auto_commit:auto_commit,
          use_offchain:use_offchain,
          public_comment:public_comment
        }
      )["id"]
    end


    # Commit a withdrawal
    #
    # Requires the "Withdraw cryptocurrencies" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#withdraw-crypto-commit-or-rollback
    #
    # ==== Params
    # +String+ +id+:: the withdrawal transaction identifier

    def withdraw_crypto_commit(id:)
      return put("wallet/crypto/withdraw/#{id}")["result"]
    end

    # Rollback a withdrawal
    #
    # Requires the "Withdraw cryptocurrencies" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#withdraw-crypto-commit-or-rollback
    #
    # ==== Params
    # +String+ +id+:: the withdrawal transaction identifier

    def withdraw_crypto_rollback(id:)
      return delete("wallet/crypto/withdraw/#{id}")["result"]
    end

    # Get an estimate of the withdrawal fee
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#estimate-withdraw-fee
    #
    # ==== Params
    # +String+ +currency+:: the currency code for withdrawal
    # +float+ +amount+:: the expected withdraw amount

    def get_estimate_withdrawal_fee(currency:, amount:)
      params = {amount:amount, currency:currency}
      return get('wallet/crypto/fee/estimate', params)["fee"]
    end


    # Converts between currencies
    # Successful response to the request does not necessarily mean the resulting transaction got executed immediately. It has to be processed first and may eventually be rolled back
    # To see whether a transaction has been finalized, call #get_transaction
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#convert-between-currencies
    #
    # ==== Params
    # +String+ +from currency+:: currency code of origin
    # +String+ +to currency+:: currency code of destiny
    # +float+ +amount+:: the amount to be converted

    def convert_between_currencies(from_currency:, to_currency:, amount:)
      return post(
        "wallet/convert",
        {
          from_currency:from_currency,
          to_currency:to_currency,
          amount:amount
        }
      )["result"]
    end

    # Check if an address is from this account
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#check-if-crypto-address-belongs-to-current-account
    #
    # ==== Params
    # +String+ +address+:: address to check

    def crypto_address_belongs_to_current_account?(address:)
      return get("wallet/crypto/address/check-mine", {address:address})["result"]
    end

    # Transfer funds between account types
    # 'source' param and 'destination' param must be different account types
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#transfer-between-wallet-and-exchange
    #
    # ==== Params
    # +String+ +currency+:: currency code for transfering
    # +float+ +amount+:: amount to be transfered
    # +String+ +source+:: transfer source account type. Either 'wallet' or 'spot'
    # +String+ +destination+:: transfer source account type. Either 'wallet' or 'spot'

    def transfer_between_wallet_and_exchange(currency:, amount:, source:, destination:)
      return post(
        'wallet/transfer',
        {
          currency:currency,
          amount:amount,
          source:source,
          destination:destination
        }
      )
    end

    # Transfer funds to another user
    #
    # Requires the "Withdraw cryptocurrencies" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#transfer-money-to-another-user
    #
    # ==== Params
    # +String+ +currency+:: currency code
    # +float+ +amount+:: amount to be transfered
    # +String+ +transfer by+:: type of identifier. Either 'email' or 'username'
    # +String+ +identifier+:: the email or username of the recieving user

    def transfer_money_to_another_user(currency:, amount:, by:, identifier:)
      return post(
        'wallet/internal/withdraw',
        {
          currency:currency,
          amount:amount,
          by:by,
          identifier:identifier
        }
      )
    end

    # Get the transaction history of the account
    # Important:
    #  - The list of supported transaction types may be expanded in future versions
    #  - Some transaction subtypes are reserved for future use and do not purport to provide any functionality on the platform
    #  - The list of supported transaction subtypes may be expanded in future versions
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-transactions-history
    #
    # ==== Params
    # +Array[String]+ +transaction ids+:: Optional. List of transaction identifiers to query
    # +Array[String]+ +transaction types+:: Optional. List of types to query. valid types are: 'DEPOSIT', 'WITHDRAW', 'TRANSFER' and 'SWAP'
    # +Array[String]+ +transaction subtyes+:: Optional. List of subtypes to query. valid subtypes are: 'UNCLASSIFIED', 'BLOCKCHAIN', 'AIRDROP', 'AFFILIATE', 'STAKING', 'BUY_CRYPTO', 'OFFCHAIN', 'FIAT', 'SUB_ACCOUNT', 'WALLET_TO_SPOT', 'SPOT_TO_WALLET', 'WALLET_TO_DERIVATIVES', 'DERIVATIVES_TO_WALLET', 'CHAIN_SWITCH_FROM', 'CHAIN_SWITCH_TO' and 'INSTANT_EXCHANGE'
    # +Array[String]+ +transaction statuses+:: Optional. List of statuses to query. valid subtypes are: 'CREATED', 'PENDING', 'FAILED', 'SUCCESS' and 'ROLLED_BACK'
    # +String+ +order by+:: Optional. sorting parameter.'created_at' or 'id'. Default is 'created_at'
    # +String+ +from+:: Optional. Interval initial value when ordering by 'created_at'. As Datetime
    # +String+ +till+:: Optional. Interval end value when ordering by 'created_at'. As Datetime
    # +String+ +id from+:: Optional. Interval initial value when ordering by id. Min is 0
    # +String+ +id till+:: Optional. Interval end value when ordering by id. Min is 0
    # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
    # +Integer+ +limit+:: Optional. Transactions per query. Defaul is 100. Max is 1000
    # +Integer+ +offset+:: Optional. Default is 0. Max is 100000

    def get_transaction_history(
      currency:nil,
      till:nil,
      types:nil,
      subtypes:nil,
      statuses:nil,
      currencies:nil,
      id_from:nil,
      id_till:nil,
      tx_ids:nil,
      order_by:nil,
      sort:nil,
      limit:nil,
      offset:nil
    )
      return get(
        "wallet/transactions",
        {
          currency:currency,
          till:till,
          types:types,
          subtypes:subtypes,
          statuses:statuses,
          currencies:currencies,
          id_from:id_from,
          id_till:id_till,
          tx_ids:tx_ids,
          order_by:order_by,
          sort:sort,
          limit:limit,
          offset:offset
        }
      )
    end

    # Get a transaction by its identifier
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-transactions-history
    #
    # ==== Params
    # +String+ +id+:: The identifier of the transaction

    def get_transaction(id:)
      return get("wallet/transactions/#{id}")
    end

    # get the status of the offchain
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#check-if-offchain-is-available
    #
    # ==== Params
    # +String+ +currency+:: currency code
    # +String+ +address+:: address identifier
    # +String+ +payment id+:: Optional.

    def offchain_available?(
      currency:,
      address:,
      payment_id:nil
    )
      return post(
        "wallet/crypto/check-offchain-available",
        {
          currency:currency,
          address:address,
          payment_id:payment_id
        }
      )["result"]
    end

    # Get the list of amount locks
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-amount-locks
    #
    # ==== Params
    # +String+ +currency+:: Optional. Currency code
    # +bool+ +active+:: Optional. value showing whether the lock is active
    # +Integer+ +limit+:: Optional. Dafault is 100. Min is 0. Max is 1000
    # +Integer+ +offset+:: Optional. Default is 0. Min is 0
    # +String+ +from+:: Optional. Interval initial value. As Datetime
    # +String+ +till+:: Optional. Interval end value. As Datetime

    def get_amount_locks(
      currency:nil,
      active:nil,
      limit:nil,
      offset:nil,
      from:nil,
      till:nil
    )
      return get(
        "wallet/amount-locks",
        {
          currency:currency,
          active:active,
          limit:limit,
          offset:offset,
          from:from,
          till:till
        }
      )
    end

    # Returns list of sub-accounts per a super account.
    #
    # Requires no API key Access Rights.
    #
    # https://api.exchange.cryptomkt.com/#sub-accounts

    def get_sub_account_list()
      return get(
        "sub-account",
      )["result"]
    end

    # Freezes sub-accounts listed
    # Sub-accounts frozen wouldn't be able to:
    # * login
    # * withdraw funds
    # * trade
    # * complete pending orders
    # * use API keys
    #
    # For any sub-account listed, all orders will be canceled and all funds will be transferred form the Trading balance
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#freeze-sub-account
    #
    # ==== Params
    # +Array[String]+ +sub_account_ids+:: A list of sub-account ids to freeze
    def freeze_sub_accounts(
      sub_account_ids:
    )
      return post(
        "sub-account/freeze",
        {
          sub_account_ids:sub_account_ids
        }
      )["result"]
    end

    # Activates sub-accounts listed. It would make sub-accounts active after being frozen
    #
    # Requires no API key Access Rights
    #
    # https://api.exchange.cryptomkt.com/#activate-sub-account
    #
    # ==== Params
    # +Array[String]+ +sub_account_ids+:: A list of sub-account ids to activate
    def activate_sub_accounts(
      sub_account_ids:
    )
      return post(
        "sub-account/activate",
        {
          sub_account_ids:sub_account_ids
        }
      )["result"]
    end

    # Transfers funds from the super-account to a sub-account or from a sub-account to the super-account
    # and returns the transaction id
    #
    # Requires the "Withdraw cryptocurrencies" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#transfer-funds
    #
    # ==== Params
    # +String+ +sub_account_ids+:: id of the sub-account to transfer funds from/to
    # +String+ +amount+:: amount to transfer
    # +String+ +currency+:: currency to transfer
    # +String+ +type+:: Direction of transfer, "to_sub_account" or "from_sub_account"
    def transfer_funds(
      sub_account_id:,
      amount:,
      currency:,
      type:
    )
      return post(
        "sub-account/transfer",
        {
          sub_account_id:sub_account_id,
          amount:amount,
          currency:currency,
          type:type
        }
      )["result"]
    end


    # Returns a list of withdrawal settings for sub-accounts listed
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-acl-settings
    #
    # ==== Params
    # +Array[String]+ +sub_account_ids+:: A list of sub-account ids to get the acl settings

    def get_acl_settings(
      sub_account_ids:
    )
      return get(
        "sub-account/acl",
        {
          sub_account_ids:sub_account_ids,
        }
      )["result"]
    end


    # Returns a list of withdrawal settings for sub-accounts listed
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-acl-settings
    #
    # ==== Params
    # +Array[String]+ +sub_account_ids+:: A list of sub-account ids to get the acl settings
    # +bool+ +deposit_address_generation_enabled+:: Optional. Enables deposits
    # +bool+ +withdraw_enabled+:: Optional. Enables withdrawals
    # +String+ +description+:: Optional. Textual description
    # +String+ +created_at+:: Optional. ACL creation time
    # +String+ +updated_at+:: Optional. ACL update time

    def change_acl_settings(
      sub_account_ids:,
      deposit_address_generation_enabled:nil,
      withdraw_enabled:nil,
      description:nil,
      created_at:nil,
      updated_at:nil
    )
      return post(
        "sub-account/acl",
        {
          sub_account_ids:sub_account_ids,
          deposit_address_generation_enabled:deposit_address_generation_enabled,
          withdraw_enabled:withdraw_enabled,
          description:description,
          created_at:created_at,
          updated_at:updated_at
        }
      )["result"]
    end


    # Returns non-zero balance values by sub-account
    # Report will include the wallet and Trading balances for each currency
    # It is functional with no regard to the state of a sub-account
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-sub-account-balance
    #
    # ==== Params
    # +String+ +sub_account_id+:: The id of the sub-account
    def get_sub_account_balance(
      sub_account_id:
    )
      return get(
          "sub-account/balance/#{sub_account_id}"
      )["result"]
    end

    # Returns sub-account crypto address for currency
    #
    # Requires the "Payment information" API key Access Right
    #
    # https://api.exchange.cryptomkt.com/#get-sub-account-crypto-address
    #
    # ==== Params
    # +String+ +sub_account_id+:: The id of the sub-account
    # +String+ +currency+:: The currency of the address
    def get_sub_account_crypto_address(
      sub_account_id:,
      currency:
    )
      return get(
          "sub-account/crypto/address/#{sub_account_id}/#{currency}"
      )["result"]["address"]
    end

  end
end