require 'test/unit'
require 'lib/cryptomarket/websocket/accountClient'
require_relative '../rest/keyloader'
require_relative '../rest/checks'

class TestWSaccount < Test::Unit::TestCase
    def setup
        @wsclient = Cryptomarket::Websocket::AccountClient.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
        @wsclient.connect
        sleep(3)
    end

    def teardown
        @wsclient.close
        sleep(2)
    end

    def test_get_balance
        msg = ""
        callback = Proc.new {|error, result| 
            if not error.nil?
                msg = "error"
            end
            result.each {|val| 
                if not goodBalance(val)
                    msg = "bad balance"
                end
            }
        }
        @wsclient.getAccountBalance(callback)
        sleep(3)
        assert(msg == "", msg)
    end

    def test_findTransactions
        msg = ""
        callback = Proc.new {|error, result| 
            if not error.nil?
                msg = "error"
                return
            end
            if result.length != 3
                msg = "wrong number of transactions"
                return
            end
            result.each {|val| 
                if not goodTransaction(val)
                    msg = "bad transaction"
                    return
                end
            }
        }
        @wsclient.findTransactions(callback, limit:3)
        sleep(3)
        assert(msg == "", msg)
    end

    def test_loadTransactions
        msg = ""
        callback = Proc.new {|error, result| 
            if not error.nil?
                msg = "error"
                return
            end
            if result.length != 3
                msg = "wrong number of transactions"
                return
            end
            result.each {|val| 
                if not goodTransaction(val)
                    msg = "bad transaction"
                    return
                end
            }
        }
        @wsclient.loadTransactions(callback, limit:3, sort:"DESC")
        sleep(3)
        assert(msg == "", msg)
    end 
end