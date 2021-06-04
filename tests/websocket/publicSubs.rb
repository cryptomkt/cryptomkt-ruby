require 'test/unit'
require 'lib/cryptomarket/websocket/publicClient'
require_relative '../rest/keyloader'
require_relative 'sequenceFlow'
require_relative 'timeFlow'
require_relative '../rest/checks'

class TestWSPublicSubs < Test::Unit::TestCase
    @@SECOND = 1
    @@MINUTE = 60
    @@HOUR = 3600
    def setup
        @wsclient = Cryptomarket::Websocket::PublicClient.new
        @wsclient.connect
    end

    def teardown
        @wsclient.close
        sleep(2)
    end

    def test_ticker_subscription
        puts "***TICKER TEST***"
        checker = TimeFlow.new
        callback = Proc.new {|result| 
            puts "ticker: " + Time.now.to_s()
            if not goodTicker(result)
                puts "not a good ticker"
            end
            if not checker.checkNextTime(result["timestamp"])
                puts "wrong flow"
            end
        }
        sleep(3 * @@SECOND)
        @wsclient.subscribeToTicker('EOSETH', callback, nil)
        sleep(10 * @@MINUTE)
        @wsclient.unsubscribeToTicker('EOSETH', nil)
        sleep(3 * @@SECOND)
    end
    
    def test_orderbook_subcsription
        puts "***ORDERBOOK TEST ***"
        checker = SequenceFlow.new
        callback = Proc.new {|feed|
            puts "orderbook: " + Time.now.to_s
            if not checker.checkNextSequence(feed["sequence"])
                puts "wrong sequence"
            end
            if not goodOrderbook(feed)
                puts "not a good orderbook"
            end
        }
        @wsclient.subscribeToOrderbook('EOSETH', callback)
        sleep(10 * @@MINUTE)
        @wsclient.unsubscribeToOrderbook('EOSETH')
        sleep(3 * @@SECOND)
    end

    def test_trades_subscription
        puts "***TRADES TEST***"
        callback = Proc.new {|feed|
            puts "trade: " + Time.now.to_s
        }
        @wsclient.subscribeToTrades('ETHBTC', callback, 2)
        sleep(10 * @@MINUTE)
        @wsclient.unsubscribeToTrades('ETHBTC')
        sleep(3 * @@SECOND)
    end
    
    def test_candles_subscription
        puts "***CANDLE TEST***"
        callback = Proc.new {|feed|
            puts "candles: " + Time.now.to_s
            feed.each{|val| 
                if not goodCandle(val) 
                    puts "not good candle" 
                end
            }  
        }
        @wsclient.subscribeToCandles('ETHBTC', 'M1', 2,callback)
        sleep(10 * @@SECOND)
        @wsclient.unsubscribeToCandles('ETHBTC', 'M1')
        sleep(3 * @@SECOND)
    end
end
