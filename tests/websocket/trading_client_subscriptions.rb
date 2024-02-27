# frozen_string_literal: true

require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/trading_client'
require_relative '../key_loader'
require_relative '../checks'
require_relative '../checker_generator'

class TestWSTradingSubs < Test::Unit::TestCase
  @@SECOND = 1
  @@MINUTE = 60
  @@HOUR = 3600
  def setup
    @wsclient = Cryptomarket::Websocket::TradingClient.new api_key: KeyLoader.api_key,
                                                           api_secret: KeyLoader.api_secret
    @wsclient.connect
    @veredict_checker = VeredictChecker.new
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def test_reports # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @wsclient.subscribe_to_reports(
      callback: gen_check_notification_list_w_n_type_callback(WSCheck.good_report, @veredict_checker),
      result_callback: gen_result_callback(@veredict_checker)
    )
    sleep(10 * @@SECOND)
    timestamp = Time.now.to_i.to_s
    symbol = 'EOSETH'
    @wsclient.create_spot_order(
      symbol: symbol, price: '10000', quantity: '0.01', side: 'sell', client_order_id: timestamp,
      callback: gen_check_result_callback(WSCheck.good_report, @veredict_checker)
    )
    sleep(10 * @@SECOND)
    @wsclient.cancel_spot_order(
      client_order_id: timestamp, callback: gen_check_result_callback(WSCheck.good_report, @veredict_checker)
    )
    sleep(5 * @@SECOND)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end

  def test_spot_balance # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @wsclient.subscribe_to_spot_balance(
      callback: gen_check_notification_list_callback(WSCheck.good_balance, @veredict_checker),
      result_callback: gen_result_callback(@veredict_checker),
      mode: 'updates'
    )
    sleep(5 * @@SECOND)
    timestamp = Time.now.to_i.to_s
    symbol = 'EOSETH'
    @wsclient.create_spot_order(
      symbol: symbol, price: '10000', quantity: '0.01', side: 'sell', client_order_id: timestamp,
      callback: gen_result_callback(@veredict_checker)
    )
    sleep(5 * @@SECOND)
    @wsclient.cancel_spot_order(client_order_id: timestamp, callback: gen_result_callback(@veredict_checker))
    sleep(5 * @@SECOND)
    @wsclient.unsubscribe_to_spot_balance(result_callback: gen_result_callback(@veredict_checker))
    sleep(5 * @@SECOND)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end
end
