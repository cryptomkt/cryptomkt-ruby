require 'test/unit'
require 'lib/cryptomarket/websocket/accountClient'
require 'lib/cryptomarket/client'
require_relative '../rest/keyloader'
require_relative '../rest/checks'

class TestWSaccount < Test::Unit::TestCase
    def setup
        @wsclient = Cryptomarket::Websocket::AccountClient.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
        @wsclient.connect
        @restclient = Cryptomarket::Client.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
    end

    def teardown
        @wsclient.close
        sleep(2)
    end

    def test_transaction_subscription
        msg = ""
        callback = Proc.new {|feed|
            if not goodTransaction(feed)
                msg = "bad transaction"
                return
            end 
        }

        @wsclient.subscribeToTransactions(callback)
        sleep(3)
        @restclient.transferMoneyFromExchangeToBank("EOS", "0.1")
        sleep(3)
        @restclient.transferMoneyFromBankToExchange("EOS", "0.1")
        sleep(3)
        assert(msg == "", msg)
    end 
end