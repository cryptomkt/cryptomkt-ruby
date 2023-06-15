require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/tradingClient'
require_relative '../keyLoader'
require_relative '../checks'
require_relative 'sequenceFlow'
require_relative 'timeFlow'

class TestWSTradingSubs < Test::Unit::TestCase
    @@SECOND = 1
    @@MINUTE = 60
    @@HOUR = 3600
    def setup
        @wsclient = Cryptomarket::Websocket::TradingClient.new api_key:Keyloader.api_key, api_secret:Keyloader.api_secret
        @wsclient.connect
    end

    def teardown
        @wsclient.close
        sleep(2)
    end

    def test_reports
        puts "***REPORT TESTS***"
        callback = Proc.new {|feed|
            puts Time.now.to_s + " report"
            puts feed
        }
        @wsclient.subscribe_to_reports(callback:callback)
        sleep(10 * @@SECOND)
        timestamp = Time.now.to_i.to_s
        symbol = 'EOSETH'
        callback = Proc.new {|error, result|
            if not error.nil?
                puts 'an error arrived'
                puts error
            else
                puts result
            end
        }
        @wsclient.create_spot_order(symbol: symbol, price:'10000', quantity:'0.01', side:'sell', client_order_id:timestamp)
        sleep(10 * @@SECOND)
        @wsclient.cancel_spot_order(client_order_id:timestamp)
        sleep(5 * @@SECOND)
    end

    def test_spot_balance
        puts "***REPORT TESTS***"
        callback = Proc.new {|feed|
            puts Time.now.to_s + " balance"
            puts feed
        }
        @wsclient.subscribe_to_spot_balance(callback:callback)
        sleep(5 * @@SECOND)
        timestamp = Time.now.to_i.to_s
        symbol = 'EOSETH'
        callback = Proc.new {|error, result|
            if not error.nil?
                puts 'an error arrived'
                puts error
            else
                puts result
            end
        }
        @wsclient.create_spot_order(symbol: symbol, price:'10000', quantity:'0.01', side:'sell', client_order_id:timestamp, callback:callback)
        sleep(5 * @@SECOND)
        @wsclient.cancel_spot_order(client_order_id:timestamp)
        sleep(5 * @@SECOND)
        @wsclient.unsubscribe_to_spot_balance(result_callback:callback)
    end
end
