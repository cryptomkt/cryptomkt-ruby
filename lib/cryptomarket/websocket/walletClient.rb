require_relative "authClient"
require_relative "../constants"

module Cryptomarket
    module Websocket

        # WalletClient connects via websocket to cryptomarket to get wallet information of the user. uses SHA256 as auth method and authenticates automatically.
        #

        class WalletClient < AuthClient
            # Creates a new client and authenticates it to the server
            # ==== Params
            # +String+ +apiKey+:: the user api key
            # +String+ +apiSecret+:: the user api secret
            # +Integer+ +window+:: Maximum difference between the creation of the request and the moment of request processing in milliseconds. Max is 60_000. Defaul is 10_000
            def initialize(apiKey:, apiSecret:, window:nil)
                transaction = "transaction"
                balance = "balance"
                super(
                    url:"wss://api.exchange.cryptomkt.com/api/3/ws/wallet",
                    apiKey:apiKey,
                    apiSecret:apiSecret,
                    window:window,
                    subscriptionKeys:{
                        "subscribe_transactions" => [transaction, Args::NotificationType::COMMAND],
                        "unsubscribe_transactions" => [transaction, Args::NotificationType::COMMAND],
                        "transaction_update" => [transaction, Args::NotificationType::UPDATE],

                        "subscribe_wallet_balances" => [balance, Args::NotificationType::COMMAND],
                        "unsubscribe_wallet_balances" => [balance, Args::NotificationType::COMMAND],
                        "wallet_balances" => [balance, Args::NotificationType::SNAPSHOT],
                        "wallet_balance_update"=> [balance, Args::NotificationType::UPDATE]
                    })
            end

            # A transaction notification occurs each time a transaction has been changed, such as creating a transaction, updating the pending state (e.g., the hash assigned) or completing a transaction
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-transactions
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a list of reports, and the type of notification (only 'update')
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a boolean value, indicating the success of the subscription

            def subscribe_to_transactions(callback:, result_callback:nil)
              sendSubscription('subscribe_transactions', callback, nil, result_callback)
            end

            # stop recieving the feed of transactions changes
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-transactions
            #
            # ==== Params
            # +Proc+ +callback+:: Optional. A +Proc+ called with a boolean value, indicating the success of the unsubscription

            def unsubscribe_to_transactions(result_callback:nil)
              sendUnsubscription('unsubscribe_transactions', result_callback, nil)
            end

            # subscribe to a feed of the user's wallet balances
            #
            # only non-zero values are present
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-wallet-balance
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ that recieves notifications as a list of balances, and the type of notification (either 'snapshot' or 'update')
            # +Proc+ +resultCallback+:: Optional. A +Proc+ called with a boolean value, indicating the success of the subscription

            def subscribe_to_wallet_balance(callback:, result_callback:nil)
              interceptor = Proc.new {|notification, type|
                if type == Args::NotificationType::SNAPSHOT
                  callback.call(notification, type)
                else
                  callback.call([notification], type)
                end
              }
              sendSubscription('subscribe_wallet_balances', interceptor, nil, result_callback)
            end

            # stop recieving the feed of balances changes
            #
            # https://api.exchange.cryptomkt.com/#subscribe-to-wallet-balance
            #
            # ==== Params
            # +Proc+ +callback+:: Optional. A +Proc+ called with a boolean value, indicating the success of the unsubscription

            def unsubscribe_to_wallet_balance(result_callback:nil)
              sendUnsubscription('unsubscribe_wallet_balances', result_callback, nil)
            end

            # Get the user's wallet balance for all currencies with balance
            #
            # https://api.exchange.cryptomkt.com/#request-wallet-balance
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ called with a list of the user balances

            def get_wallet_balances(callback:)
              sendById('wallet_balances', callback)
            end

            # Get the user's wallet balance of a currency
            #
            # Requires the "Payment information" API key Access Right
            #
            # https://api.exchange.cryptomkt.com/#request-wallet-balance
            #
            # ==== Params
            # +String+ +currency+:: The currency code to query the balance
            # +Proc+ +callback+:: A +Proc+ called with an user balance

            def get_wallet_balance_of_currency(currency:, callback:)
              sendById('wallet_balance', callback, {currency:currency})
            end


            # Get the transaction history of the account
            # Important:
            #  - The list of supported transaction types may be expanded in future versions
            #  - Some transaction subtypes are reserved for future use and do not purport to provide any functionality on the platform
            #  - The list of supported transaction subtypes may be expanded in future versions
            #
            # Requires the "Payment information" API key Access Right
            #
            # https://api.exchange.cryptomkt.com/#get-transactions
            #
            # ==== Params
            # +Proc+ +callback+:: A +Proc+ called with a list of transactions
            # +Array[String]+ +tx_ids+:: Optional. List of transaction identifiers to query
            # +Array[String]+ +types+:: Optional. List of types to query. valid types are: 'DEPOSIT', 'WITHDRAW', 'TRANSFER' and 'SWAP'
            # +Array[String]+ +subtyes+:: Optional. List of subtypes to query. valid subtypes are: 'UNCLASSIFIED', 'BLOCKCHAIN', 'AIRDROP', 'AFFILIATE', 'STAKING', 'BUY_CRYPTO', 'OFFCHAIN', 'FIAT', 'SUB_ACCOUNT', 'WALLET_TO_SPOT', 'SPOT_TO_WALLET', 'WALLET_TO_DERIVATIVES', 'DERIVATIVES_TO_WALLET', 'CHAIN_SWITCH_FROM', 'CHAIN_SWITCH_TO' and 'INSTANT_EXCHANGE'
            # +Array[String]+ +statuses+:: Optional. List of statuses to query. valid subtypes are: 'CREATED', 'PENDING', 'FAILED', 'SUCCESS' and 'ROLLED_BACK'
            # +Array[String] +currencies+:: Optional. List of currencies ids.
            # +String+ +from+:: Optional. Interval initial value when ordering by 'created_at'. As Datetime
            # +String+ +till+:: Optional. Interval end value when ordering by 'created_at'. As Datetime
            # +String+ +id_from+:: Optional. Interval initial value when ordering by id. Min is 0
            # +String+ +id_till+:: Optional. Interval end value when ordering by id. Min is 0
            # +String+ +order_by+:: Optional. sorting parameter.'created_at' or 'id'. Default is 'created_at'
            # +String+ +sort+:: Optional. Sort direction. 'ASC' or 'DESC'. Default is 'DESC'
            # +Integer+ +limit+:: Optional. Transactions per query. Defaul is 100. Max is 1000
            # +Integer+ +offset+:: Optional. Default is 0. Max is 100000

            def get_transactions(
              callback:,
              tx_ids:nil,
              types:nil,
              subtypes:nil,
              statuses:nil,
              currencies:nil,
              from:nil,
              till:nil,
              id_from:nil,
              id_till:nil,
              order_by:nil,
              sort:nil,
              limit:nil,
              offset:nil
            )
              sendById('get_transactions', callback, {
                tx_ids:tx_ids,
                types:types,
                subtypes:subtypes,
                statuses:statuses,
                currencies:currencies,
                from:from,
                till:till,
                id_from:id_from,
                id_till:id_till,
                order_by:order_by,
                sort:sort,
                limit:limit,
                offset:offset
              })
            end
        end
    end
end