# frozen_string_literal: true

require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/wallet_client'
require_relative '../key_loader'
require_relative '../checks'

class TestWSWalletClient < Test::Unit::TestCase
  def setup
    @wsclient = Cryptomarket::Websocket::WalletClient.new api_key: KeyLoader.api_key, api_secret: KeyLoader.api_secret
    @wsclient.connect
    sleep(3)
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def check_result(checker, result)
    if result.is_a?(Array)
      result.each do |val|
        return val.to_s unless checker.call(val)
      end
    elsif !checker.call(result)
      result.to_s
    end
    ''
  end

  def gen_checker_callback(checker)
    err_msg = ''
    callback = proc { |error, result|
      unless error.nil?
        err_msg = error.to_s
        return
      end
      err_msg = check_result(checker, result)
    }
    { msg: err_msg, callback: callback }
  end

  def test_get_wallet_balances
    hash = gen_checker_callback(->(balance) { good_balance(balance) })
    @wsclient.get_wallet_balances(callback: hash[:callback])
    sleep(2)
    assert(hash[:msg] == '', hash[:msg])
  end

  def test_get_wallet_balance
    hash = gen_checker_callback(->(balance) { good_balance(balance) })
    @wsclient.get_wallet_balance(callback: hash[:callback], currency: 'EOS')
    sleep(2)
    assert(hash[:msg] == '', hash[:msg])
  end

  def test_get_transactions
    hash = gen_checker_callback(->(transaction) { good_transaction(transaction) })
    @wsclient.get_transactions(callback: hash[:callback])
    sleep(2)
    assert(hash[:msg] == '', hash[:msg])
  end
end
