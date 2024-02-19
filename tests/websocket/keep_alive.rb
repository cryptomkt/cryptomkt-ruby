require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/market_data_client'
require_relative '../key_loader'

class TestWStrading < Test::Unit::TestCase
  def setup
    @wsclient = Cryptomarket::Websocket::MarketDataClient.new
    @wsclient.connect
    sleep(3)
  end

  @@result_callback = proc { |error, result|
    if !error.nil?
      puts error
    else
      puts result
    end
  }
  @@feed_callback = proc { |_feed|
    puts 'feed: ' + Time.now.to_s
  }

  def test_keep_socket_alive
    @wsclient.subscribe_to_ticker callback: @@feed_callback, result_callback: @@result_callback, speed: '1s'
    sleep(3 * 60 * 60)
  end
end
