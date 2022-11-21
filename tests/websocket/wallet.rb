require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/walletClient'
require_relative '../rest/key_loader'
require_relative '../rest/checks'

class TestWSWalletClient < Test::Unit::TestCase
    def setup
        @wsclient = Cryptomarket::Websocket::WalletClient.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
        @wsclient.connect
        sleep(3)
    end

    def teardown
        @wsclient.close
        sleep(2)
    end

    def gen_checker_callback(checker)
      msg = ""
      callback = Proc.new {|error, result|
        if not error.nil?
          msg = error.to_s
          return
        end
        if result.kind_of?(Array)
          result.each {|val|
            if not checker.call(val)
              msg = "bad val: #{val}"
            end
          }
        else
          if not checker.call(result)
            msg = "bad val: #{result}"
          end
        end
      }
      return {msg:msg, callback:callback}
    end

    def test_get_wallet_balances
      hash = gen_checker_callback(->(balance){ return goodBalance(balance)})
      @wsclient.get_wallet_balances(callback:hash[:callback])
      sleep(2)
      assert(hash[:msg]=="", hash[:msg])
    end

    def test_get_wallet_balance
      hash = gen_checker_callback(->(balance){ return goodBalance(balance)})
      @wsclient.get_wallet_balance_of_currency(callback:hash[:callback], currency:"EOS")
      sleep(2)
      assert(hash[:msg]=="", hash[:msg])
    end

    def test_get_transactions
      hash = gen_checker_callback(->(transaction) {return goodTransaction(transaction)})
      @wsclient.get_transactions(callback:hash[:callback])
      sleep(2)
      assert(hash[:msg]=="", hash[:msg])
    end
end