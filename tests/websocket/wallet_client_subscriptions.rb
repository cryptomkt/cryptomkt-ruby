# frozen_string_literal: true

require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/wallet_client'
require_relative '../../lib/cryptomarket/client'
require_relative '../key_loader'
require_relative '../checks'
require_relative '../checker_generator'

class TestWSaccount < Test::Unit::TestCase
  def setup
    @wsclient = Cryptomarket::Websocket::WalletClient.new api_key: KeyLoader.api_key, api_secret: KeyLoader.api_secret
    @wsclient.connect
    @restclient = Cryptomarket::Client.new api_key: KeyLoader.api_key, api_secret: KeyLoader.api_secret
    @veredict_checker = VeredictChecker.new
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def test_transaction_and_balance_subscription # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    @wsclient.subscribe_to_transactions(
      callback: gen_check_notification_w_n_type_callback(WSChecks.good_transaction, @veredict_checker),
      result_callback: gen_result_callback(@veredict_checker)
    )
    sleep(3)
    @restclient.transfer_between_wallet_and_exchange(
      currency: 'EOS',
      amount: '0.1',
      source: 'spot',
      destination: 'wallet'
    )
    sleep(3)
    @wsclient.subscribe_to_wallet_balance(
      callback: gen_check_notification_list_w_n_type_callback(WSChecks.good_balance, @veredict_checker),
      result_callback: gen_result_callback(@veredict_checker)
    )
    sleep(3)
    @restclient.transfer_between_wallet_and_exchange(
      currency: 'EOS',
      amount: '0.1',
      source: 'wallet',
      destination: 'spot'
    )
    sleep(3)
    @wsclient.unsubscribe_to_transactions(result_callback: gen_result_callback(@veredict_checker))
    sleep(3)
    @wsclient.unsubscribe_to_wallet_balance(result_callback: gen_result_callback(@veredict_checker))
    sleep(3)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end
end
