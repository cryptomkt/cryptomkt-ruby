# CryptoMarket-Ruby
[main page](https://www.cryptomkt.com/)


[sign up in CryptoMarket](https://www.cryptomkt.com/account/register).

# Installation
To install Cryptomarket use gem
```
gem install cryptomarket-sdk
```
# Documentation

[The api documentation](https://api.exchange.cryptomkt.com/)


# Quick Start

## rest client
```ruby
require "cryptomarket"

# instance a client
api_key='AB32B3201'
api_secret='21b12401'
client = Cryptomarket::Client.new apiKey:apiKey, apiSecret:apiSecret

# get currencies
currencies = client.getCurrencies()

# get order books
order_book = client.getOrderbook('EOSETH')

# get your account balances
account_balance = client.getAccountBalance()

# get your trading balances
trading_balance = client.getTradingBalance()

# move balance from account bank to account trading
result = client.transferMoneyFromBankToExchange('ETH', '3.2')

# get your active orders
orders = client.getActiveOrders('EOSETH')

# create a new order
order = client.createOrder('EOSETH', 'buy', '10', order_type=args.ORDER_TYPE.MARKET)
```

## websocket client

All websocket calls work with callbacks, subscriptions also use a callback with one argument for the subscription feed. All the other callbacks takes two arguments, err and result: callback(err, result). If the transaction is successful err is None and the result is in result. If the transaction fails, result is None and the error is in err.

callbacks are callables like Procs

There are three websocket clients, the PublicClient, the TradingClient and the AccountClient.

```ruby
require "cryptomarket-sdk"

# THE PUBLIC CLIENT

wsclient = Cryptomarket::Websocket::PublicClient.new

wsclient.connect() # blocks until connected

my_callback = Proc.new {|err, data|
    if not err.nil?
        puts err # deal with error
        return
    end
    puts data
}

# get currencies
wsclient.getCurrencies(my_callback)


# get an order book feed, 
# feed_callback is for the subscription feed, with one argument
# result_callback is for the subscription result (success or failure)
feed_callback = Proc.new {|feed|
    puts feed
}

wsclient.subscribeToOrderbook('EOSETH', feed_callback, my_callback)

# THE TRADING CLIENT

wsclient = Cryptomarket::Websocket::TradingClient.new apiKey:apiKey, apiSecret:apiSecret

wsclient.connect() # blocks until connected and authenticated.

# get your trading balances
wsclient.getTradingBalance(my_callback)

# get your active orders
wsclient.getActinveOrders(my_callback)

# create a new order
wsclient.create_order(
    clientOrderId:"123123",
    symbol:'EOSETH', 
    side:'buy', 
    quantity:"10",
    price:"10",
    callback:my_callback)

# THE ACCONUT CLIENT

wsclient = Cryptomarket::Websocket::AccountClient apiKey:apiKey, apiSecret:apiSecret

wsclient.connect() # blocks until connected

wsclient.getAccountBalance(my_callback)
```


## exception handling
```ruby
require "cryptomarket-sdk"

client = Cryptomarket::Client.new apiKey:apiKey, apiSecret:apiSecret

# catch a wrong argument 
begin
    order = client.create_order(
        symbol='EOSETH', 
        side='selllll', # wrong
        quantity='3'
    )
rescue Cryptomarket::SDKException => e:
    puts e
end

# catch a failed transaction
begin
    order = client.create_order(
        symbol='eosehtt',  # non existant symbol
        side='sell',
        quantity='10', 
    )
rescue Cryptomarket::SDKException => e:
    puts e
end

wsclient = Cryptomarket::Websocket::TradingClient.new apiKey:apiKey, apiSecret:apiSecret

# websocket errors are passed as the first argument to the callback
my_callback = Proc.new {|err, data|
    if not err.nil?
        puts err # deal with error
        return
    end
    puts data
}

wsclient.getTradingBalance(my_callback)

# catch authorization error
# to catch an authorization error on client connection, a on_error function must be defined on the client
wsclient = TradingClient(apiKey, apiSecret)
wsclient.onerror = Proc.new {|error| puts "error", error}
wsclient.connect


```
# Checkout our other SDKs

[node sdk](https://github.com/cryptomkt/cryptomkt-node)

[java sdk](https://github.com/cryptomkt/cryptomkt-java)

[go sdk](https://github.com/cryptomkt/cryptomkt-go)

[python sdk](https://github.com/cryptomkt/cryptomkt-python)
