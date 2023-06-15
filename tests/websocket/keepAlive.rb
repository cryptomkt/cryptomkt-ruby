require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/marketDataClient'
require_relative '../keyLoader'

class TestWStrading < Test::Unit::TestCase
    def setup
        @wsclient = Cryptomarket::Websocket::MarketDataClient.new
        @wsclient.connect
        sleep(3)
    end

    @@result_callback = Proc.new {|error, result| 
        if not error.nil?
            puts error
        else
            puts result
        end
    }
    @@feed_callback = Proc.new {|feed| 
        puts "feed: " + Time.now.to_s
    }

    def test_keep_socket_alive
        @wsclient.subscribe_to_ticker callback:@@feed_callback, result_callback:@@result_callback, speed:'1s'
        sleep(3*60*60)
    end
end