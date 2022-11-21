require 'test/unit'
require 'lib/cryptomarket/websocket/tradingClient'
require_relative '../rest/key_loader'
require_relative 'sequenceFlow'
require_relative 'timeFlow'
require_relative '../rest/checks'

class TestWSTradingSubs < Test::Unit::TestCase
    @@SECOND = 1
    @@MINUTE = 60
    @@HOUR = 3600
    def setup
        @wsclient = Cryptomarket::Websocket::TradingClient.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
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
end
