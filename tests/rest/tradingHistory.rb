require 'test/unit'
require 'lib/cryptomarket/client'
require_relative 'keyloader'
require_relative 'checks'

class TestRestTradingMethods < Test::Unit::TestCase
    def setup
        @client = Cryptomarket::Client.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
    end

    def test_get_order_history
        result = @client.getOrderHistory limit:12
        result.each {|val| assert(goodOrder(val))}
        
    end

    def test_get_orders
        result = @client.getOrders '1609518444'
        result.each {|val| assert(goodOrder(val))}
    end

    def test_get_trades_history
        result = @client.getTradeHistory symbol:'EOSETH'
        result.each {|val| assert(goodTrade(val))}
    end

    def test_get_trades_by_order_by_id
        result = @client.getTradesByOrderId '337789472575'
        result.each {|val| assert(goodTrade(val))}
    end
end