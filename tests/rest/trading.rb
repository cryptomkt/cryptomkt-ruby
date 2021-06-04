require 'test/unit'
require 'lib/cryptomarket/client'
require_relative 'keyloader'
require_relative 'checks'

class TestRestTradingMethods < Test::Unit::TestCase
    def setup
        @client = Cryptomarket::Client.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
    end

    def test_get_trading_balance
        result = @client.getTradingBalance
        result.each {|val| assert(goodBalance(val))}
    end

    def test_get_active_orders
        result = @client.getActiveOrders
        result.each {|val| assert(goodOrder(val))}
    end
    
    def test_order_flow
        timestamp = Time.now.to_i.to_s
        order = @client.createOrder symbol:'EOSETH', price:'10000', quantity:'0.01', side:'sell', clientOrderId:timestamp
        assert(goodOrder(order))
        orders = @client.getActiveOrder timestamp
        assert(goodOrder(order))
        order = @client.cancelOrder timestamp
        assert(goodOrder(order))
        assert(order["status"] == "canceled")
    end

    # def test_cancel_all_orders
    #     timestamp = Time.now.to_i.to_s
    #     @client.cancelAllOrders
    #     @client.createOrder symbol:'EOSETH', price:'10000', quantity:'0.01', side:'sell', clientOrderId:timestamp
    #     @client.createOrder symbol:'EOSETH', price:'10000', quantity:'0.01', side:'sell'
    #     result = @client.getActiveOrders
    #     assert(result.length == 2)
    #     @client.cancelAllOrders 'ETHBTC'
    #     result = @client.getActiveOrders
    #     assert(result.length == 2)
    #     @client.cancelAllOrders
    #     result = @client.getActiveOrders
    #     assert(result.length == 0)
    # end

    def test_trading_fee
        result = @client.tradingFee 'EOSETH'
        if not result.key? "takeLiquidityRate" or not result.key? "provideLiquidityRate"
            assert(false)
        end
    end
end