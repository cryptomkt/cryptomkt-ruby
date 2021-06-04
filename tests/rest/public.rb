require 'test/unit'
require 'lib/cryptomarket/client'
require_relative 'checks'

class TestRestPublicMethods < Test::Unit::TestCase
    def setup
        @client = Cryptomarket::Client.new
    end

    def test_get_currencies
        result = @client.getCurrencies
        result.each { |val| assert(goodCurrency(val))}
    end

    def test_get_2_currencies
        result = @client.getCurrencies ['EOS', 'CRO']
        result.each {|val| assert(goodCurrency(val))}
    end

    def test_get_symbols
        result = @client.getSymbols
        result.each {|val| assert(goodSymbol(val))}
    end

    def test_get_2_symbols
        result = @client.getSymbols ['XLMETH', 'PAXGUSD']
        result.each {|val| assert(goodSymbol(val))}
    end

    def test_get_currency
        result = @client.getCurrency 'USDT'
        assert(goodCurrency(result))
    end

    def test_get_symbol
        result = @client.getSymbol 'BTCCOP'
        assert(goodSymbol(result)) 
    end

    def test_get_tickers
        result = @client.getTickers
        nullTickers = Hash.new
    
        nullTickers["BTCEUR"] = true
        nullTickers["ETHCLP"] = true
        nullTickers["ETHMXN"] = true
        nullTickers["ETHUYU"] = true
        nullTickers["ETHBRL"] = true
        nullTickers["BTCARS"] = true
        nullTickers["ETHCOP"] = true
        nullTickers["BTCUYU"] = true
        nullTickers["BTCCOP"] = true
        nullTickers["ETHVEF"] = true
        nullTickers["ETHARS"] = true
        nullTickers["ETHPEN"] = true
        nullTickers["BTCCLP"] = true
        nullTickers["BTCMXN"] = true
        nullTickers["BTCBRL"] = true
        nullTickers["ETHEUR"] = true
        nullTickers["BTCPEN"] = true
        nullTickers["BTCVEF"] = true
    
        result.each {|val|
            if not nullTickers.key? val["symbol"]
                assert(goodTicker(val))
            end
        }
    end

    def test_get_2_tickers
        result = @client.getTickers ['XLMETH', 'PAXGUSD']
        result.each {|val| assert(goodTicker(val))}
    end

    def test_get_ticker
        result = @client.getTicker 'XLMETH'
        assert(goodTicker(result))
    end

    def test_get_trades
        result = @client.getTrades symbols: ['XLMETH', 'EOSETH'], limit: 1
        result.each do |key, trades|
            trades.each {|val| assert(goodPublicTrade(val))}
        end
    end

    def test_get_orderbooks
        result = @client.getOrderbooks symbols: ['EOSETH', 'XLMETH'], limit: 2
        result.each do |key, val|
            assert(goodOrderbook(val))
        end
    end

    def test_get_orderbook
        result = @client.getOrderbook 'EOSETH', limit: 2
        assert(goodOrderbook(result))
    end

    def test_get_candles
        result = @client.getCandles symbols: ['EOSETH'], limit: 2
        result.each do |key, candles|
            candles.each {|val| assert(goodCandle(val))}
        end
    end
end