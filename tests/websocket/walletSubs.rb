require 'test/unit'
require 'lib/cryptomarket/websocket/walletClient'
require 'lib/cryptomarket/client'
require_relative '../rest/key_loader'
require_relative '../rest/checks'

class TestWSaccount < Test::Unit::TestCase
    def setup
        @wsclient = Cryptomarket::Websocket::WalletClient.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
        @wsclient.connect
        @restclient = Cryptomarket::Client.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
    end

    def teardown
        @wsclient.close
        sleep(2)
    end

    def test_transaction_subscription
        msg = ""
        callback = Proc.new {|notification, type|
            print notification
            if not goodTransaction(notification)
                msg = "bad transaction"
                return
            end
        }

        @wsclient.subscribe_to_transactions(callback:callback)
        sleep(3)
        @restclient.transfer_between_wallet_and_exchange(
          currency:"EOS",
          amount:"0.1",
          source:'wallet',
          destination:'spot',
        )
        sleep(3)
        @wsclient.subscribe_to_wallet_balance(callback:Proc.new {|feed, type|
            print feed
        })
        sleep(3)
        @restclient.transfer_between_wallet_and_exchange(
          currency:"EOS",
          amount:"0.1",
          source:'spot',
          destination:'wallet',
        )
        sleep(3)
        @wsclient.unsubscribe_to_transactions()
        assert(msg == "", msg)
    end

    def test_balance_subscription
        msg = ""
        callback = Proc.new {|notification,type|
            print notification
            # if not goodBalances(notification)
            #     msg = "bad balances"
            #     return
            # end
        }
        @wsclient.subscribe_to_wallet_balance(callback:callback)
        sleep(3)
        @wsclient.unsubscribe_to_wallet_balance()
    end
end