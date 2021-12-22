require_relative "HttpManager"
require_relative "utils"

module Cryptomarket
    class Client
        include Utils

        def initialize(apiKey:nil, apiSecret:nil)
            @httpManager = HttpManager.new apiKey:apiKey, apiSecret:apiSecret
        end

        def publicGet(endpoint, params=nil)
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

        def delete(endpoint, params=nil)
            return @httpManager.makeRequest(method:'delete', endpoint:endpoint, params:params)
        end

        
        ################
        # public calls #
        ################

        # Get a list of all currencies or specified currencies
        #
        # https://api.exchange.cryptomkt.com/#currencies
        #
        # Params:
        # +Array[String]+ +currencies+:: Optional. A list of currencies ids

        def getCurrencies(currencies=nil)
            params = Hash.new
            if not currencies.nil?
                params['currencies'] = currencies
            end
            return publicGet('public/currency/', params)
        end

        # Get the data of a currency
        # 
        # https://api.exchange.cryptomkt.com/#currencies
        #
        # Params:
        # +String+ +currency+:: A currency id
        
        def getCurrency(currency)
            return publicGet("public/currency/#{currency}")
        end

        # Get a list of all symbols or for specified symbols
        # 
        # A symbol is the combination of the base currency (first one) and quote currency (second one)
        #
        # https://api.exchange.cryptomkt.com/#symbols
        #
        # Params:
        # +Array[String]+ +symbols+:: Optional. A list of symbol ids
        
        def getSymbols (symbols=nil) 
            params = Hash.new
            if not symbols.nil?
                params['symbols'] = symbols
            end
            return publicGet('public/symbol/', params)
        end

        # Get a symbol by its id
        # 
        # A symbol is the combination of the base currency (first one) and quote currency (second one)
        # 
        # https://api.exchange.cryptomkt.com/#symbols
        #
        # Params:
        # +String+ +symbol+:: A symbol id
        
        def getSymbol(symbol)
            return publicGet("public/symbol/#{symbol}")
        end

        # Get tickers for all symbols or for specified symbols
        # 
        # https://api.exchange.cryptomkt.com/#tickers
        #
        # Params:
        # +Array[String]+ +symbols+:: Optional. A list of symbol ids
        
        def getTickers(symbols=nil)
            params = Hash.new
            if not symbols.nil?
                params['symbols'] = symbols
            end
            return publicGet('public/ticker/', params)
        end

        # Get the ticker of a symbol
        # 
        # https://api.exchange.cryptomkt.com/#tickers
        #
        # Params:
        # +String+ +symbol+:: A symbol id
        
        def getTicker(symbol)
            return publicGet("public/ticker/#{symbol}")
        end

        # Get trades for all symbols or for specified symbols
        # 
        # 'from' param and 'till' param must have the same format, both index of both timestamp
        # 
        # https://api.exchange.cryptomkt.com/#trades
        #
        # Params:
        # +Array[String]+ +symbols+:: Optional. A list of symbol ids
        # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
        # +String+ +from+:: Optional. Initial value of the queried interval
        # +String+ +till+:: Optional. Last value of the queried interval
        # +Integer+ +limit+:: Optional. Trades per query. Defaul is 100. Max is 1000
        # +Integer+ +offset+:: Optional. Default is 0. Max is 100000
        
        def getTrades(symbols:nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil)
            params = Hash.new
            if not symbols.nil?
                params['symbols'] = symbols
            end
            extend_hash_with_pagination! params, sort:sort, from:from, till:till, limit:limit, offset:offset
            return publicGet('public/trades/', params)
        end

    

        # Get trades of a symbol
        # 
        # 'from' param and 'till' param must have the same format, both index of both timestamp
        # 
        # https://api.exchange.cryptomkt.com/#trades
        #
        # Params:
        # +String+ +symbol+:: A symbol id
        # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
        # +String+ +from+:: Optional. Initial value of the queried interval
        # +String+ +till+:: Optional. Last value of the queried interval
        # +Integer+ +limit+:: Optional. Trades per query. Defaul is 100. Max is 1000
        # +Integer+ +offset+:: Optional. Default is 0. Max is 100000
        
        def getTradesOfSymbol(symbol=nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil)
            params = Hash.new
            params['symbol'] = symbol
            extend_hash_with_pagination! params, sort:sort, from:from, till:till, limit:limit, offset:offset
            return publicGet('public/trades/', params)
        end

        

        # Get orderbooks for all symbols or for the specified symbols
        # 
        # An Order Book is an electronic list of buy and sell orders for a specific symbol, structured by price level
        # 
        # https://api.exchange.cryptomkt.com/#order-book
        #
        # Params:
        # +Array[String]+ +symbols+:: Optional. A list of symbol ids
        # +Integer+ +limit+:: Optional. Limit of order book levels. Set to 0 to view full list of order book levels
        
        def getOrderbooks(symbols:nil, limit:nil)
            params = Hash.new
            if not symbols.nil?
                params['symbols'] = symbols
            end
            if not limit.nil?
                params['limit'] = limit
            end
            return publicGet('public/orderbook/', params)
        end

        

        # Get order book of a symbol
        # 
        # An Order Book is an electronic list of buy and sell orders for a specific symbol, structured by price level
        # 
        # https://api.exchange.cryptomkt.com/#order-book
        #
        # Params:
        # +String+ +symbol+:: The symbol id
        # +Integer+ +limit+:: Optional. Limit of order book levels. Set to 0 to view full list of order book levels
        
        def getOrderbook(symbol, limit:nil)
            params = Hash.new
            if not limit.nil?
                params['limit'] = limit
            end
            return publicGet("public/orderbook/#{symbol}", params)
        end

        

        # Get order book of a symbol with market depth info
        # 
        # An Order Book is an electronic list of buy and sell orders for a specific symbol, structured by price level
        # 
        # https://api.exchange.cryptomkt.com/#order-book
        #
        # Params:
        # +String+ +symbol+:: The symbol id
        # +Integer+ +volume+:: Desired volume for market depth search
        
        def getMarketDepth(symbol, volume:nil)
            params = Hash.new
            if not limit.nil?
                params['volume'] = volume
            end
            return publicGet("public/orderbook/#{symbol}", params)
        end

        # Get candles for all symbols or for specified symbols
        # 
        # Candels are used for OHLC representation
        # 
        # https://api.exchange.cryptomkt.com/#candles
        #
        # Params:
        # +Array[String]+ +symbols+:: Optional. A list of symbol ids
        # +String+ +period+:: Optional. A valid tick interval. 'M1' (one minute), 'M3', 'M5', 'M15', 'M30', 'H1' (one hour), 'H4', 'D1' (one day), 'D7', '1M' (one month). Default is 'M30'
        # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
        # +String+ +from+:: Optional. Initial value of the queried interval
        # +String+ +till+:: Optional. Last value of the queried interval
        # +Integer+ +limit+:: Optional. Candles per query. Defaul is 100. Max is 1000
        # +Integer+ +offset+:: Optional. Default is 0. Max is 100000
        
        def getCandles(symbols:nil, period:nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil)
            params = Hash.new
            if not symbols.nil?
                params['symbols'] = symbols
            end
            if not period.nil?
                params['period'] = period
            end
            extend_hash_with_pagination! params, sort:sort, from:from, till:till, limit:limit, offset:offset
            return publicGet('public/candles/', params)
        end

        # Get candle for all symbols or for specified symbols
        # 
        # Candels are used for OHLC representation
        # 
        # https://api.exchange.cryptomkt.com/#candles
        #
        # Params:
        # +String+ +symbol+:: A symbol id
        # +String+ +period+:: Optional. A valid tick interval. 'M1' (one minute), 'M3', 'M5', 'M15', 'M30', 'H1' (one hour), 'H4', 'D1' (one day), 'D7', '1M' (one month). Default is 'M30'
        # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
        # +String+ +from+:: Optional. Initial value of the queried interval
        # +String+ +till+:: Optional. Last value of the queried interval
        # +Integer+ +limit+:: Optional. Candles per query. Defaul is 100. Max is 1000
        # +Integer+ +offset+:: Optional. Default is 0. Max is 100000
        
        def getCandlesOfSymbol(symbol:, period:nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil)
            params = Hash.new
            if not period.nil?
                params['period'] = period
            end
            extend_hash_with_pagination! params, sort:sort, from:from, till:till, limit:limit, offset:offset
            return publicGet("public/candles/#{symbol}", params)
        end

        #################
        # Trading calls #
        #################

        # Get the account trading balance
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#trading-balance
        
        def getTradingBalance
            return get('trading/balance')
        end

        # Get the account active orders
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#get-active-orders
        #
        # Params:
        # +String+ +symbol+:: Optional. A symbol for filtering active orders
        
        def getActiveOrders(symbol=nil)
            params = Hash.new
            if not symbol.nil?
                params['symbol'] = symbol
            end 
            return get('order', params)
        end

        # Get an active order by its client order id
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#get-active-orders
        #
        # Params:
        # +String+ +clientOrderId+:: The clientOrderId of the order
        # +Integer+ +wait+:: Optional. Time in milliseconds Max value is 60000. Default value is None. While using long polling request: if order is filled, cancelled or expired order info will be returned instantly. For other order statuses, actual order info will be returned after specified wait time.
        
        def getActiveOrder(clientOrderId, wait=nil)
            params = Hash.new
            if not wait.nil?
                params["wait"] = wait
            end 
            return get("order/#{clientOrderId}", params)
        end

        # Creates a new order
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#create-new-order
        #
        # Params:
        # +String+ +symbol+::Trading symbol
        # +String+ +side+::'buy' or 'sell'
        # +String+ +quantity+::Order quantity
        # +String+ +clientOrderId+:: Optional. If given must be unique within the trading day, including all active orders. If not given, is generated by the server
        # +String+ +type+:: Optional. 'limit', 'market', 'stopLimit' or 'stopMarket'. Default is 'limit'
        # +String+ +timeInForce+:: Optional. 'GTC', 'IOC', 'FOK', 'Day', 'GTD'. Default to 'GTC'
        # +String+ +price+:: Required for 'limit' and 'stopLimit'. limit price of the order
        # +String+ +stopPrice+:: Required for 'stopLimit' and 'stopMarket' orders. stop price of the order
        # +String+ +expireTime+:: Required for orders with timeInForce = GDT
        # +bool+ +strictValidate+:: Optional. If False, the server rounds half down for tickerSize and quantityIncrement. Example of ETHBTC: tickSize = '0.000001', then price '0.046016' is valid, '0.0460165' is invalid 
        # +bool+ +postOnly+:: Optional. If True, your post_only order causes a match with a pre-existing order as a taker, then the order will be cancelled
        
        def createOrder(symbol:, side:, quantity:, clientOrderId:nil, type:nil, timeInForce:nil, price:nil, stopPrice:nil, expireTime:nil, strictValidate:nil, postOnly:nil)
            params = {'symbol': symbol, 'side': side, 'quantity': quantity}
            extend_hash_with_order_params! params, type:type, timeInForce:timeInForce, price:price, stopPrice:stopPrice, expireTime:expireTime, strictValidate:strictValidate, postOnly:postOnly
            if not clientOrderId.nil?
                return put("order/#{clientOrderId}", params)
            end
            return post("order", params)
        end

        # Cancel all active orders, or all active orders for a specified symbol
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#cancel-orders
        # 
        # +string+ +symbol+:: Optional. If given, cancels all orders of the symbol. If not given, cancels all orders of all symbols
        
        def cancelAllOrders(symbol=nil)
            params = Hash.new
            if not symbol.nil?
                params['symbol'] = symbol
            end
            return delete("order", params)
        end

        # Cancel the order with clientOrderId
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#cancel-order-by-clientorderid
        #
        # Params:
        # +String+ +clientOrderId+:: the client id of the order to cancel
        
        def cancelOrder(clientOrderId)
            delete("order/#{clientOrderId}")
        end

        # Get personal trading commission rates for a symbol
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#get-trading-commission
        # 
        # +string+ +symbol+:: The symbol of the comission rates
        
        def tradingFee(symbol)
            return get("trading/fee/#{symbol}")
        end

        ####################
        # trading history #
        ####################

        # Get the account order history
        # 
        # All not active orders older than 24 are deleted
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#orders-history
        #
        # Params:
        # +String+ +symbol+:: Optional. Filter orders by symbol
        # +String+ +from+:: Optional. Initial value of the queried interval
        # +String+ +till+:: Optional. Last value of the queried interval
        # +Integer+ +limit+:: Optional. Trades per query. Defaul is 100. Max is 1000
        # +Integer+ +offset+:: Optional. Default is 0. Max is 100000
        
        def getOrderHistory(symbol:nil, from:nil, till:nil, limit:nil, offset:nil)
            params = Hash.new
            if not symbol.nil?
                params['symbol'] = symbol
            end
            extend_hash_with_pagination! params, from:from, till:till, limit:limit, offset:offset
            return get('history/order', params)
        end

        # Get orders with the clientOrderId
        # 
        # All not active orders older than 24 are deleted
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#orders-history
        #
        # Params:
        # +String+ +clientOrderId+:: the clientOrderId of the orders
        
        def getOrders(clientOrderId)
            params = {clientOrderId:clientOrderId}
            return get("history/order", params)
        end

        # Get the user's trading history
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#orders-history
        #
        # Params:
        # +String+ +symbol:: Optional. Filter trades by symbol
        # +String+ +sort:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
        # +String+ +by:: Optional. Defines the sorting type.'timestamp' or 'id'. Default is 'timestamp'
        # +String+ +from:: Optional. Initial value of the queried interval. Id or datetime
        # +String+ +till:: Optional. Last value of the queried interval. Id or datetime
        # +Integer+ +limit:: Optional. Trades per query. Defaul is 100. Max is 1000
        # +Integer+ +offset:: Optional. Default is 0. Max is 100000
        # +String+ +margin:: Optional. Filtering of margin orders. 'include', 'only' or 'ignore'. Default is 'include'

        def getTradeHistory(symbol:nil, sort:nil, by:nil, from:nil, till:nil, limit:nil, offset:nil, margin:nil)
            params = Hash.new
            if not symbol.nil?
                params['symbol'] = symbol
            end
            if not margin.nil?
                params['margin'] = margin
            end
            extend_hash_with_pagination! params, sort:sort, by:by, from:from, till:till, limit:limit, offset:offset
            return get('history/trades')
        end

        # Get the account's trading order with a specified order id
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#trades-by-order
        #
        # Params:
        # +String+ +id+:: Order unique identifier assigned by exchange
        # 

        def getTradesByOrderId(id)
            return get("history/order/#{id}/trades")
        end

        ######################
        # Account Management #
        ######################

        # Get the user account balance
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#account-balance
        
        def getAccountBalance
            return get("account/balance")
        end

        # Get the current address of a currency
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#deposit-crypto-address
        #
        # Params:
        # +String+ +currency+:: currency to get the address
        
        def getDepositCryptoAddress(currency)
            return get("account/crypto/address/#{currency}")
        end

        # Creates a new address for the currency
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#deposit-crypto-address
        #
        # Params:
        # +String+ +currency+:: currency to create a new address
        
        def createDepositCryptoAddress(currency)
            return post("account/crypto/address/#{currency}")
        end

        # Get the last 10 addresses used for deposit by currency
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#last-10-deposit-crypto-address
        #
        # Params:
        # +String+ +currency+:: currency to get the list of addresses
        
        def getLast10DepositCryptoAddresses(currency)
            return get("account/crypto/addresses/#{currency}")
        end

        # Get the last 10 unique addresses used for withdraw by currency
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#last-10-used-crypto-address
        #
        # Params:
        # +String+ +currency+:: currency to get the list of addresses
        
        def getLast10UsedCryptoAddresses(currency)
            return get("account/crypto/used-addresses/#{currency}")
        end

        # Withdraw cryptocurrency
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#withdraw-crypto
        #
        # Params:
        # +String+ +currency+:: currency code of the crypto to withdraw 
        # +Integer+ +amount+:: the amount to be sent to the specified address
        # +String+ +address+:: the address identifier
        # +String+ +paymentId+:: Optional.
        # +bool+ +includeFee+:: Optional. If true then the total spent amount includes fees. Default false
        # +bool+ +autoCommit+:: Optional. If false then you should commit or rollback transaction in an hour. Used in two phase commit schema. Default true
        
        def withdrawCrypto(currency:, amount:, address:, paymentId:nil, includeFee:nil, autoCommit:nil)
            # FORBIDDEN ERROR
            params = {currency:currency, amount:amount, address:address}
            if not paymentId.nil?
                params['paymentId'] = paymentId
            end
            if not includeFee.nil?
                params['includeFee'] = includeFee
            end
            if not autoCommit.nil?
                params['autoCommit'] = autoCommit
            end
            return post("account/crypto/withdraw", params)
        end

        # Converts between currencies
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#transfer-convert-between-currencies
        #
        # Params:
        # +String+ +fromCurrency+:: currency code of origin
        # +String+ +toCurrency+:: currency code of destiny
        # +Integer+ +amount+:: the amount to be sent
        
        def transferConvert(fromCurrency, toCurrency, amount)
            #FORBIDDEN ERROR
            params = {fromCurrency:fromCurrency, toCurrency:toCurrency, amount:amount}
            return post('account/crypto/transfer-convert', params)
        end

        # Commit a withdrawal of cryptocurrency
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#withdraw-crypto-commit-or-rollback
        #
        # Params:
        # +String+ +id+:: the withdrawal transaction identifier
        
        def commitWithdrawCrypto(id)
            # cannot be tested <= withdraw crypto is forbidden
            return put("account/crypto/withdraw/#{id}")
        end

        # Rollback a withdrawal of cryptocurrency
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#withdraw-crypto-commit-or-rollback
        #
        # Params:
        # +String+ +id+:: the withdrawal transaction identifier
        
        def rollbackWithdrawCrypto(id) 
            # cannot be tested <= withdraw crypto is forbidden
            return delete("account/crypto/withdraw/#{id}")
        end

        # Get an estimate of the withdrawal fee
        # 
        # Requires authetication
        # 
        # https://api.exchange.cryptomkt.com/#estimate-withdraw-fee
        #
        # Params:
        # +String+ +currency+:: the currency code for withdraw
        # +Integer+ +amount+:: the expected withdraw amount
        
        def getEstimateWithdrawFee(currency, amount)
            params = {amount:amount, currency:currency}
            return get('account/crypto/estimate-withdraw', params)
        end

        # Check if an address is from this account
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#check-if-crypto-address-belongs-to-current-account
        #
        # Params:
        # +String+ +address+:: The address to check
        
        def checkIfCryptoAddressIsMine(address)
            return get("account/crypto/is-mine/#{address}")
        end

        # Transfer money from the trading balance to the account balance
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#transfer-money-between-trading-account-and-bank-account
        #
        # Params:
        # +String+ +currency+:: Currency code for transfering
        # +Integer+ +amount+:: Amount to be transfered
        
        def transferMoneyFromBankToExchange(currency, amount)
            params = {currency:currency, amount:amount, type:'bankToExchange'}
            return post('account/transfer', params)
        end

        # Transfer money from the account balance to the trading balance
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#transfer-money-between-trading-account-and-bank-account
        #
        # Params:
        # +String+ +currency+:: Currency code for transfering
        # +Integer+ +amount+:: Amount to be transfered
        
        def transferMoneyFromExchangeToBank(currency, amount)
            params = {currency:currency, amount:amount, type:'exchangeToBank'}
            return post('account/transfer', params)
        end

        # Transfer money to another user
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#transfer-money-to-another-user-by-email-or-username
        #
        # Params:
        # +String+ +currency+:: currency code
        # +Integer+ +amount+:: amount to be transfered between balances
        # +String+ +by+:: either 'email' or 'username'
        # +String+ +identifier+:: the email or the username
        
        def transferMonyToAnotherUser(currency, amount, by, identifier)
            params = {currency:currency, amount:amount, by:by, identifier:identifier}
            return post('account/transfer/internal', params)
        end

        # Get the transactions of the account by currency
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#get-transactions-history
        #
        # Params:
        # +String+ +currency+:: Currency code to get the transaction history
        # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'.
        # +String+ +by+:: Optional. Defines the sorting type.'timestamp' or 'id'. Default is 'timestamp'
        # +String+ +from+:: Optional. Initial value of the queried interval. Id or datetime
        # +String+ +till+:: Optional. Last value of the queried interval. Id or datetime
        # +Integer+ +limit+:: Optional. Transactions per query. Defaul is 100. Max is 1000
        # +Integer+ +offset+:: Optional. Default is 0. Max is 100000
        
        def getTransactionHistory(currency:, sort:nil, by:nil, from:nil, till:nil, limit:nil, offset:nil)
            params = {currency:currency}
            extend_hash_with_pagination! params, sort:sort, by:by, from:from, till:till, limit:limit, offset:offset
            return get("account/transactions", params)
        end

        # Get the transactions of the account by its identifier
        # 
        # Requires authentication
        # 
        # https://api.exchange.cryptomkt.com/#get-transactions-history
        #
        # Params:
        # +String+ +id+:: The identifier of the transaction
        
        def getTransaction(id)
            return get("account/transactions/#{id}")
        end
    end
end