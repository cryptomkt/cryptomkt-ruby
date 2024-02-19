require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/wallet_client'
require_relative '../key_loader'
require_relative '../checks'

class TestWSWalletClient < Test::Unit::TestCase
  def setup
    @wsclient = Cryptomarket::Websocket::WalletClient.new api_key: Keyloader.api_key, api_secret: Keyloader.api_secret
    @wsclient.connect
    sleep(3)
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def gen_checker_callback(checker)
    msg = ''
    callback = proc { |error, result|
      unless error.nil?
        msg = error.to_s
        return
      end
      if result.is_a?(Array)
        result.each do |val|
          msg = "bad val: #{val}" unless checker.call(val)
        end
      elsif !checker.call(result)
        msg = "bad val: #{result}"
      end
    }
    { msg: msg, callback: callback }
  end

  def test_get_wallet_balances
    hash = gen_checker_callback(->(balance) { goodBalance(balance) })
    @wsclient.get_wallet_balances(callback: hash[:callback])
    sleep(2)
    assert(hash[:msg] == '', hash[:msg])
  end

  def test_get_wallet_balance
    hash = gen_checker_callback(->(balance) { goodBalance(balance) })
    @wsclient.get_wallet_balance_of_currency(callback: hash[:callback], currency: 'EOS')
    sleep(2)
    assert(hash[:msg] == '', hash[:msg])
  end

  def test_get_transactions
    hash = gen_checker_callback(->(transaction) { goodTransaction(transaction) })
    @wsclient.get_transactions(callback: hash[:callback])
    sleep(2)
    assert(hash[:msg] == '', hash[:msg])
  end
end
