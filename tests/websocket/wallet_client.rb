# frozen_string_literal: true

require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/wallet_client'
require_relative '../key_loader'
require_relative '../checks'
require_relative '../checker_generator'

class TestWSWalletClient < Test::Unit::TestCase
  def setup
    @wsclient = Cryptomarket::Websocket::WalletClient.new api_key: KeyLoader.api_key, api_secret: KeyLoader.api_secret
    @wsclient.connect
    sleep(3)
    @veredict_checker = VeredictChecker.new
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def test_get_wallet_balances
    @wsclient.get_wallet_balances(
      callback: gen_check_result_list_callback(WSChecks.good_balance, @veredict_checker)
    )
    sleep(2)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end

  def test_get_wallet_balance
    @wsclient.get_wallet_balance(
      currency: 'EOS',
      callback: gen_check_result_callback(WSChecks.good_balance, @veredict_checker)
    )
    sleep(2)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end

  def test_get_transactions
    @wsclient.get_transactions(
      callback: gen_check_result_list_callback(WSChecks.good_transaction, @veredict_checker)
    )
    sleep(2)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end
end
