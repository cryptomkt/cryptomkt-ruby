require 'test/unit'
require 'lib/cryptomarket/client'
require 'lib/cryptomarket/exceptions'
require_relative 'keyloader'

class TestRestTradingMethods < Test::Unit::TestCase
    def setup
        @client = Cryptomarket::Client.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
    end

    def test_not_authorized_exception
        client = Cryptomarket::Client.new apiKey:'not a key', apiSecret:'not a key'
        begin
            result = @client.getTradingBalance
        rescue Cryptomarket::APIException => exception
            puts exception
            puts exception.code
            puts exception.message
            puts exception.description
        end
    end

    def test_not_funds
        begin
            result = @client.createOrder symbol: "EOSETH",  quantity:"100000", side:"sell", price:"0.01"
        rescue Cryptomarket::APIException => exception
            puts exception
            puts exception.code
            puts exception.message
            puts exception.description
        end
    end
end