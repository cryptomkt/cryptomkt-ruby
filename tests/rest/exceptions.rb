# frozen_string_literal: true

require 'test/unit'
require_relative '../../lib/cryptomarket/client'
require_relative '../../lib/cryptomarket/exceptions'
require_relative '../key_loader'

class TestRestTradingMethods < Test::Unit::TestCase # rubocop:disable Style/Documentation
  def setup
    @client = Cryptomarket::Client.new api_key: Keyloader.api_key, api_secret: Keyloader.api_secret
  end

  def test_not_authorized_exception
    @client = Cryptomarket::Client.new api_key: 'not a key', api_secret: 'not a key'
    begin
      @client.get_spot_trading_balances
    rescue Cryptomarket::APIException => e
      assert_equal(e.code, 1_002)
    end
  end

  def test_not_funds
    @client.create_spot_order symbol: 'EOSETH', quantity: '100000', side: 'sell', price: '0.01'
  rescue Cryptomarket::APIException => e
    assert_equal(e.code, 20_001)
  end
end
