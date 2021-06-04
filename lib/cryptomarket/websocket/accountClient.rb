require_relative "authClient"
require_relative"../utils"

module Cryptomarket
    module Websocket
            
        # AccountClient connects via websocket to cryptomarket to get account information of the user. uses SHA256 as auth method and authenticates automatically.
        #
        # +string+ +apiKey+:: the user api key
        # +string+ +apiSecret+:: the user api secret
        # +Proc+ +callback+:: Optional. A +Proc+ to call with the client once the connection is established and the authentication is successful. if an error ocurrs is return as the fist parameter of the callback: callback(err, client)

        class AccountClient < AuthClient
            include Utils
            # Creates a new client and authenticates it to the server
            def initialize(apiKey:, apiSecret:)
                super(url:"wss://api.exchange.cryptomkt.com/api/2/ws/account", apiKey:apiKey, apiSecret:apiSecret)
            end

            # get the account balance as a list of balances. non-zero balances only
            #
            # https://api.exchange.cryptomarket.com/#request-balance
            
            def getAccountBalance(callback)
                sendById('getBalance', callback)
            end

            # Get a list of transactions of the account. Accepts only filtering by Datetime
            #
            # https://api.exchange.cryptomarket.com/#find-transactions
            #
            # Parameters:
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            # +string+ +currency+:: Optional. Currency to filter transactions by.
            # +string+ +sort+:: Optional. sort direction. 'ASC' or 'DESC' default is 'DESC'
            # +string+ +from+:: Optional. Initial value of the queried interval
            # +string+ +till+:: Optional. Last value of the queried interval
            # +integer+ +limit+:: Optional. Trades per query. Defaul is 100. Max is 1000
            # +integer+ +offset+:: Optional. Default is 0. Max is 100000
            # +bool+ +showSenders+:: Optional. If true incluedes senders addresses. Default is false.

            def findTransactions(callback, currency:nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil, showSenders:nil)
                params = Hash.new
                if not currency.nil?
                    params['currency'] = currency
                end
                if not showSenders.nil?
                    params['showSenders'] = showSenders
                end
                extend_hash_with_pagination! params, sort:sort, from:from, till:till, limit:limit, offset:offset
                sendById('findTransactions', callback, params)
            end

            # LoadTransactions gets a list of transactions of the account. Accepts only filtering by Index
            #
            # https://api.exchange.cryptomarket.com/#find-transactions
            #
            # Parameters:
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            # +string+ +currency+:: Optional. Currency to filter transactions by.
            # +string+ +sort+:: Optional. sort direction. 'ASC' or 'DESC' default is 'ASC'
            # +string+ +from+:: Optional. Initial value of the queried interval (Included)
            # +string+ +till+:: Optional. Last value of the queried interval (Excluded)
            # +integer+ +limit+:: Optional. Trades per query. Defaul is 100. Max is 1000
            # +integer+ +offset+:: Optional. Default is 0. Max is 100000
            # +bool+ +showSenders+:: Optional. If true incluedes senders addresses. Default is false.
            
            def loadTransactions(callback, currency:nil, sort:nil, from:nil, till:nil, limit:nil, offset:nil, showSenders:nil)
                params = Hash.new
                if not currency.nil?
                    params['currency'] = currency
                end
                if not showSenders.nil?
                    params['showSenders'] = showSenders
                end
                extend_hash_with_pagination! params, sort:sort, from:from, till:till, limit:limit, offset:offset
                sendById('loadTransactions', callback, params)
            end

            # subscribes to a feed of transactions
            #
            # A transaction notification occurs each time the transaction has been changed:
            # such as creating a transaction, updating the pending state (for example the hash assigned)
            # or completing a transaction. This is the easiest way to track deposits or develop real-time asset monitoring.
            #
            # A combination of the recovery mechanism and transaction subscription provides reliable and consistent information
            # regarding transactions. For that, you should store the latest processed index and
            # requested possible gap using a "loadTransactions" method after connecting or reconnecting the Websocket.
            #
            # https://api.exchange.cryptomarket.com/#subscription-to-the-transactions
            #
            # +Proc+ +callback+:: A +Proc+ to call with the result data. It takes one argument. a feed of reports
            # +Proc+ +resultCallback+:: Optional. A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def subscribeToTransactions(callback, resultCallback:nil)
                sendSubscription('subscribeTransactions', callback, {}, resultCallback)
            end

            # unsubscribe to the transaction feed.
            #
            # https://api.exchange.cryptomkt.com/#subscription-to-the-transactions
            #
            # +Proc+ +callback+:: Optional. A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}
            
            def unsubscribeToTransactions(callback:nil)
                sendUnsubscription('unsubscribeTransactions', callback, {})
            end
        end
    end
end