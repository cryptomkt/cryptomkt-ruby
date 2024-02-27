# frozen_string_literal: true

require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/market_data_client'
require_relative '../key_loader'
require_relative '../checks'

class TestWSClientLifetime < Test::Unit::TestCase
  @@SECOND = 1
  @@MINUTE = 60
  @@HOUR = 3600

  def test_public_client_lifetime
    @wsclient = Cryptomarket::Websocket::MarketDataClient.new

    @wsclient.on_close = proc { puts 'closing' }
    @wsclient.on_connect = proc { puts 'connected' }
    @wsclient.on_error = proc { |error| puts 'error', error }

    @wsclient.connect
    sleep(5 * @@SECOND)
    @wsclient.close
    sleep(2 * @@SECOND)
  end
end
