require 'test/unit'
require_relative '../../lib/cryptomarket/client'
require_relative '../../lib/cryptomarket/exceptions'
require_relative '../keyLoader'

class TestRestTradingMethods < Test::Unit::TestCase
    def setup
        @client = Cryptomarket::Client.new api_key:Keyloader.api_key, api_secret:Keyloader.api_secret
    end

    def test_not_authorized_exception
        client = Cryptomarket::Client.new api_key:'not a key', api_secret:'not a key'
        begin
            result = @client.get_spot_trading_balance
        rescue Cryptomarket::APIException => exception
            puts exception
            puts exception.code
            puts exception.message
            puts exception.description
        end
    end

    def test_not_funds
        begin
            result = @client.create_spot_order symbol: "EOSETH",  quantity:"100000", side:"sell", price:"0.01"
        rescue Cryptomarket::APIException => exception
            puts exception
            puts exception.code
            puts exception.message
            puts exception.description
        end
    end
end