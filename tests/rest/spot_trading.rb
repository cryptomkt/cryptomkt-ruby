require 'test/unit'
require_relative '../../lib/cryptomarket/client'
require_relative 'key_loader'
require_relative 'checks'

class TestRestTradingMethods < Test::Unit::TestCase
    def setup
      @client = Cryptomarket::Client.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
    end

    def test_get_spot_trading_balance
      result = @client.get_spot_trading_balance
      assert(goodList(lambda do |val| goodBalance(val) end, result))
    end

    def test_get_spot_trading_balance_of_currency
      result = @client.get_spot_trading_balance_of_currency currency:"USDT"
      assert(goodBalance(result))
    end

    def get_all_active_spot_orders
        result = @client.getActiveOrders
        result.each {|val| assert(goodOrder(val))}
    end

    def test_spot_order_lifecycle
        timestamp = Time.now.to_i.to_s
        order = @client.create_spot_order(
          symbol:'EOSETH',
          price:'10000',
          quantity:'0.01',
          side:'sell',
          client_order_id:timestamp
        )
        assert(goodOrder(order))
        order = @client.get_active_spot_order client_order_id:timestamp
        assert(goodOrder(order))

        new_client_order_id = Time.now.to_i.to_s + "1"
        order = @client.replace_spot_order(
          client_order_id:order["client_order_id"],
          new_client_order_id:new_client_order_id,
          quantity:"0.02",
          price:"999"
        )
        assert(goodOrder(order))
        order = @client.cancel_spot_order client_order_id:new_client_order_id
        assert(goodOrder(order))
        assert(order["status"] == "canceled")
    end

    def test_cancel_all_spot_orders
      result = @client.cancel_all_spot_orders
      assert(goodList(lambda do |val| goodOrder(val) end, result))
    end

    def test_get_all_trading_commission
      result = @client.get_all_trading_commission
      assert(goodList(lambda do |val| goodTradingCommission(val) end, result))
    end

    def test_get_trading_commission
        result = @client.get_trading_commission symbol:'EOSETH'
        assert(goodTradingCommission(result))
    end
end