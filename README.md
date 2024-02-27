# CryptoMarket-Ruby

[main page](https://www.cryptomkt.com/)

[sign up in CryptoMarket](https://www.cryptomkt.com/account/register).

# Installation

To install Cryptomarket use gem

```
gem install cryptomarket-sdk
```

# Documentation

This sdk makes use of the [api version 3](https://api.exchange.cryptomkt.com/) of cryptomarket

# Quick Start

## rest client

```ruby
require "cryptomarket-sdk"

# instance a client
api_key='AB32B3201'
api_secret='21b12401'
client = Cryptomarket::Client.new api_key:api_key, api_secret:api_secret

# get currencies
currencies = client.get_currencies

# get order books
order_book = client.get_orderbooks symbols:['EOSETH']

# get your account balances
account_balance = client.get_wallet_balances

# get your trading balances
trading_balance = client.get_spot_trading_balances

# move balance from account bank to account trading
result = @client.transfer_between_wallet_and_exchange(
  currency: "CRO",
  amount: "0.1",
  source:"wallet",
  destination:"spot",
)

# get your active orders
orders = client.get_all_active_spot_orders('EOSETH')

# create a new order
order = client.create_spot_order(
  symbol:'EOSETH',
  side:'buy',
  quantity:'10',
  order_type:args.ORDER_TYPE.MARKET
)
```

## Websocket Clients

Ahere are three websocket clients, the `MarketDataClient`, the `TradingClient` and the `WalletClient`. The `MarketDataClient` is public, while the others require authentication to be used.

All websocket methods take Procs for their callbacks. These procs take two argument, the first is a possible error in the call (such as missing arguments), and the result data of the method.

Subscriptions also take in a Proc of two parameters, the notification data, and the notification type. The notification type is of type Args::NotificationType, and is either SNAPSHOT, NOTIFICATION or DATA, corresponding to the strings 'snapshot', 'update' and 'data'

The documentation of a specific subscriptions explains with of this types of notification uses.

### Websocket Market Data Client

There are no unsubscriptions methods for the `MarketDataClient`. To stop recieving messages is recomended to close the `MarketDataClient`.

```ruby
# instance a client
client = Cryptomarket::Websocket::MarketDataClient.new
client.connect
# close the client
client.close
# subscribe to public trades
client.subscribe_to_trades(
  callback:Proc.new {|notification, type|
    if type == Args::NotificationType::UPDATE
      puts "an update"
    end
    if type == Args::NotificationType::SNAPSHOT
      puts "a snapshot"
    end
    puts notification
  },
  symbols:['eoseth', 'ethbtc'],
  limit:2,
  result_callback:Proc.new {|err, result|
    if not err.nil?
      puts err
    else
      puts result
    end
  }
)

# subscribe to symbol tickers
client.subscribe_to_ticker(
  speed:"1s",
  callback:Proc.new {|notificatoin, type|
    if type == Args::NotificationType::DATA
      puts "is always data"
    end
    puts notification
  },
  symbols:['eoseth', 'ethbtc'],
  result_callback:Proc.new {|err, result|
    if not err.nil?
      puts err
    else
      puts result
    end
  }
)
```

### Websocket Trading Client

Subscription callback to spot trading balances takes only one argument, a list of balances (see example below)

```ruby
# instance a client with a 15 seconds window
client = Cryptomarket::Websocket::TradingClient.new(
  api_key:Keyloader.api_key,
  api_secret:Keyloader.api_secret,
  window:15_000
)
client.connect
# close the client
client.close

# subscribe to order reports
client.subscribe_to_reports(
  callback:Proc.new {|notification, type|
      if type == Args::NotificationType::UPDATE
        puts "a lonely report in a list"
      end
      if type == 'snapshot' # same as Args::NotificationType::SNAPSHOT
        puts "reports of active orders"
      end
      puts notification
  }
)
# unsubscribe from order reports
client.unsubscribe_to_reports

@wsclient.subscribe_to_spot_balance(
  callback: ->(balances) {puts balances},
  result_callback: ->(_) {},
  mode: 'updates'
)

client_order_id = Time.now.to_i.to_s

# create an order
client.create_spot_order(
  symbol: symbol,
  price:'10000',
  quantity:'0.01',
  side:'sell',
  clientOrderId:client_order_id
)

# candel an order
client.cancel_spot_order(client_order_id)

```

### Websocket Wallet Management Client

Subscription callback to transactions takes only one argument, a transaction (see example below)

```ruby
# instance a client with a default window of 10 seconds
client = Cryptomarket::Websocket::WalletClient.new api_key:Keyloader.api_key, api_secret:Keyloader.api_secret
client.connect
# close the client
defer client.close

# subscribe to wallet transactions
def callback(transaction):
  ->(transaction) { puts(transaction) }

client.subscribe_to_transactions(callback)

# unsubscribe from wallet transactions
client.unsubscribe_to_transactions(lambda { |is_success| 
  puts('successful unsubscription') if is_success
})

# get wallet balances
client.get_wallet_balances(->(balances){ puts balances})
```

## exception handling

```ruby
require "cryptomarket-sdk"

client = Cryptomarket::Client.new api_key:api_key, api_secret:api_secret

# catch a wrong argument
begin
    order = client.create_spot_order(
        symbol='EOSETH',
        side='selllll', # wrong
        quantity='3'
    )
rescue Cryptomarket::SDKException => e:
    puts e
end

# catch a failed transaction
begin
    order = client.create_spot_order(
        symbol='eosehtt',  # non existant symbol
        side='sell',
        quantity='10',
    )
rescue Cryptomarket::SDKException => e:
    puts e
end

wsclient = Cryptomarket::Websocket::TradingClient.new api_key:api_key, api_secret:api_secret

# websocket errors are passed as the first argument to the callback. valid for all non subscription methods
my_callback = Proc.new {|err, data|
    if not err.nil?
        puts err # deal with error
        return
    end
    puts data
}

wsclient.get_spot_trading_balances(my_callback)

# catch authorization error
# to catch an authorization error on client connection, a on_error function must be defined on the client
wsclient = TradingClient(api_key, api_secret)
wsclient.onerror = Proc.new {|error| puts "error", error}
wsclient.connect
```

# Checkout our other SDKs

[node sdk](https://github.com/cryptomkt/cryptomkt-node)

[java sdk](https://github.com/cryptomkt/cryptomkt-java)

[go sdk](https://github.com/cryptomkt/cryptomkt-go)

[python sdk](https://github.com/cryptomkt/cryptomkt-python)
