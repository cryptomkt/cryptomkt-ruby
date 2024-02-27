# frozen_string_literal: true

require 'test/unit'
require_relative '../../lib/cryptomarket/client'
require_relative '../key_loader'
require_relative '../checks'

class TestRestTradingMethods < Test::Unit::TestCase
  def setup
    @client = Cryptomarket::Client.new api_key: KeyLoader.api_key, api_secret: KeyLoader.api_secret
  end

  def test_get_spot_orders_history
    result = @client.get_spot_orders_history limit: 12
    result.each { |val| assert(Check.good_order(val)) }
  end

  def test_get_spot_trades_history
    result = @client.get_spot_trades_history symbol: 'EOSETH'
    result.each { |val| assert(Check.good_trade(val)) }
  end
end
