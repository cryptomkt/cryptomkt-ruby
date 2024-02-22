# frozen_string_literal: true

require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/trading_client'
require_relative '../key_loader'
require_relative '../checks'
require_relative '../checker_generator'

#
class TestWStrading < Test::Unit::TestCase # rubocop:disable Metrics/ClassLength
  def setup
    @wsclient = Cryptomarket::Websocket::TradingClient.new api_key: KeyLoader.api_key, api_secret: KeyLoader.api_secret
    @wsclient.connect
    @veredict_checker = VeredictChecker.new
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def test_get_spot_trading_balance
    @wsclient.get_spot_trading_balance(
      callback: gen_check_result_callback(WSChecks.good_balance, @veredict_checker), currency: 'EOS'
    )
    sleep(3)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end

  def test_get_spot_trading_balances
    @wsclient.get_spot_trading_balances(
      callback: gen_check_result_list_callback(WSChecks.good_balance, @veredict_checker)
    )
    sleep(3)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end

  def test_order_work_flow # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    timestamp = Time.now.to_i.to_s
    symbol = 'EOSETH'
    @wsclient.create_spot_order(
      client_order_id: timestamp, symbol: symbol, side: 'sell', price: '10000', quantity: '0.01',
      callback: gen_check_result_callback(WSChecks.good_report, @veredict_checker)
    )
    sleep(3)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
    @wsclient.get_active_spot_orders(callback: gen_check_result_list_callback(WSChecks.good_report, @veredict_checker))
    sleep(3)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)

    new_timestamp = Time.now.to_i.to_s
    @wsclient.replace_spot_order(
      client_order_id: timestamp, new_client_order_id: new_timestamp, price: '20000', quantity: '0.02',
      callback: gen_check_result_callback(WSChecks.good_report, @veredict_checker)
    )
    sleep(3)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
    @wsclient.get_active_spot_orders(callback: gen_check_result_list_callback(WSChecks.good_report, @veredict_checker))
    sleep(3)
    @wsclient.cancel_spot_order(
      client_order_id: new_timestamp, callback: gen_check_result_callback(WSChecks.good_report, @veredict_checker)
    )
    sleep(3)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end

  def test_cancel_spot_orders # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @wsclient.cancel_spot_orders
    symbol = 'EOSETH'
    @wsclient.create_spot_order(
      client_order_id: Time.now.to_i.to_s, symbol: symbol, side: 'sell', price: '10000', quantity: '0.01',
      callback: gen_check_result_callback(WSChecks.good_report, @veredict_checker)
    )
    sleep(3)
    @wsclient.create_spot_order(
      client_order_id: Time.now.to_i.to_s, symbol: symbol, side: 'sell', price: '10000', quantity: '0.01',
      callback: gen_check_result_callback(WSChecks.good_report, @veredict_checker)
    )
    sleep(3)
    @wsclient.get_active_spot_orders(callback: gen_check_result_list_callback(WSChecks.good_report, @veredict_checker))
    sleep(3)
    @wsclient.cancel_spot_orders(callback: gen_check_result_list_callback(WSChecks.good_report, @veredict_checker))
    sleep(3)
    @wsclient.get_active_spot_orders(callback: gen_check_result_list_callback(WSChecks.good_report, @veredict_checker))
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end

  def test_get_spot_commissions
    @wsclient.get_spot_commissions(
      callback: gen_check_result_list_callback(WSChecks.good_commission, @veredict_checker)
    )
    sleep(3)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end

  def test_get_spot_commission
    @wsclient.get_spot_commission(
      symbol: 'EOSETH', callback: gen_check_result_callback(WSChecks.good_commission, @veredict_checker)
    )
    sleep(3)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end

  def test_create_spot_order_list # rubocop:disable Metrics/MethodLength
    first_order_id = Time.now.to_s
    @wsclient.create_spot_order_list(
      order_list_id: first_order_id,
      contingency_type: Cryptomarket::Args::Contingency::AON,
      orders: [
        {
          'symbol' => 'EOSETH',
          'side' => Cryptomarket::Args::Side::SELL,
          'quantity' => '0.1',
          'time_in_force' => Cryptomarket::Args::TimeInForce::FOK,
          'price' => '1000'
        },
        {
          'symbol' => 'EOSUSDT',
          'side' => Cryptomarket::Args::Side::SELL,
          'quantity' => '0.1',
          'time_in_force' => Cryptomarket::Args::TimeInForce::FOK,
          'price' => '1000'
        }
      ],
      callback: gen_check_result_callback(WSChecks.good_report, @veredict_checker)
    )
    sleep(5)
    assert(@veredict_checker.good_veredict?, @veredict_checker.err_msg)
  end
end
