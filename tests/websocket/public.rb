require 'test/unit'
require 'lib/cryptomarket/websocket/publicClient'
require_relative '../rest/checks'


class TestWSpublic < Test::Unit::TestCase
    def setup
        @wsclient = Cryptomarket::Websocket::PublicClient.new
        @wsclient.connect
    end

    def teardown
        @wsclient.close
        sleep(2)
    end

    def test_get_currencies
        msg = ""
        @wsclient.getCurrencies( Proc.new {|error, result| 
            if not error.nil?
                msg = "error"
            end
            if result.length == 0
                msg = "no currencies"
            end
            result.each {|val| 
                if not goodCurrency(val)
                    msg = "bad currency"
                end
            }
        })
        sleep(3)
        assert(msg == "", msg)
    end

    def test_get_currency
        msg = ""
        result = @wsclient.getCurrency('EOS', Proc.new {|error, result| 
            if not error.nil?
                msg = "error"
            end
            if not goodCurrency(result)
                msg = "bad currency"
            end
        })
        sleep(3)
        assert(msg == "", msg)
    end


    def test_get_error
        msg = ""
        result = @wsclient.getCurrency('EOSS', Proc.new {|error, result| 
            if error.nil?
                msg = "error"
            end
            if not result.nil?
                msg = "error"
            end
        })
        sleep(3)
        assert(msg == "", msg)
    end

    def test_get_symbols
        msg = ""
        result = @wsclient.getSymbols(Proc.new {|error, result| 
            if not error.nil?
                msg = "error"
            end
            if result.length == 0
                msg = "no symbols"
            end
            result.each {|val| 
                if not goodSymbol(val)
                    msg = "bad symbol"
                end
            }
        })
        sleep(3)
        assert(msg == "", msg)
    end

    def test_get_symbol
        msg = ""
        result = @wsclient.getSymbol('EOSETH', Proc.new {|error, result| 
            if not error.nil?
                msg = "error"
            end
            if not goodSymbol(result)
                msg = "bad symbol"
            end
        })
        sleep(3)
        assert(msg == "", msg)
    end

    def test_get_trades
        msg = ""
        callback = Proc.new {|error, result| 
            if not error.nil?
                msg = "error"
            end
            if result.length == 0
                msg = "no trades"
            end
            result.each {|val| 
                if not goodPublicTrade(val)
                    msg = "bad public trade"
                end
            }
        }
        result = @wsclient.getTrades 'EOSETH', callback, limit: 2
        sleep(3)
        assert(msg == "", msg)
    end
end