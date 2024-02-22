# frozen_string_literal: true

require 'concurrent'
require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/trading_client'
require_relative '../key_loader'
require_relative '../checks'

#
class TestWStrading < Test::Unit::TestCase # rubocop:disable Metrics/ClassLength
  def setup
    @wsclient = Cryptomarket::Websocket::TradingClient.new api_key: Keyloader.api_key, api_secret: Keyloader.api_secret
    @wsclient.connect
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def gen_check_result_callback(_check_fn)
    future = Concurrent::Promises.resolvable_future
    callback = proc { |err, _result|
      err_msg = ''
      err_msg = err unless err.nil?
      # err_msg = "check failed: #{result}" if check_fn.call(result)
      future.fulfill err_msg
    }
    [callback, future]
  end

  def gen_list_checker_callback(checker)
    msg = ''
    callback = proc do |error, result|
      msg = error.to_s unless error.nil?
      result.each do |val|
        msg = "bad val: #{val}" unless checker.call(val)
      end
    end
    { msg: msg, callback: callback }
  end

  def gen_checker_callback(checker)
    msg = ''
    callback = proc do |error, result|
      msg = error.to_s unless error.nil?
      msg = "bad val: #{result}" unless checker.call(result)
    end
    { msg: msg, callback: callback }
  end

  def test_get_spot_trading_balance
    hash = gen_checker_callback(->(balance) { good_balance(balance) })
    @wsclient.get_spot_trading_balance(callback: hash[:callback], currency: 'EOS')
    sleep(3)
    assert(hash[:msg] == '', hash[:msg])
  end

  def test_get_spot_trading_balances
    hash = gen_list_checker_callback(lambda { |balance|
      puts balance
      good_balance(balance)
    })
    @wsclient.get_spot_trading_balances(callback: hash[:callback])
    sleep(3)
    assert(hash[:msg] == '', hash[:msg])
  end

  def test_order_work_flow # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    timestamp = Time.now.to_i.to_s
    symbol = 'EOSETH'
    hash = gen_checker_callback(->(order) { good_order(order) })
    @wsclient.create_spot_order(
      client_order_id: timestamp,
      symbol: symbol,
      side: 'sell',
      price: '10000',
      quantity: '0.01',
      callback: hash[:callback]
    )
    sleep(3)
    assert(hash[:msg] == '', hash[:msg])
    hash2 = gen_checker_callback(lambda { |result|
      result.each do |order|
        return true if order['client_order_id'] == timestamp
      end
      false
    })
    @wsclient.get_active_spot_orders(callback: hash2[:callback])
    sleep(3)
    assert(hash2[:msg] == '', hash2[:msg])

    new_timestamp = Time.now.to_i.to_s
    @wsclient.replace_spot_order(
      client_order_id: timestamp,
      new_client_order_id: new_timestamp,
      price: '20000',
      quantity: '0.02',
      callback: hash[:callback]
    )
    sleep(3)
    assert(hash[:msg] == '', hash[:msg])
    hash3 = gen_checker_callback(lambda { |result|
      result.each do |order|
        return true if order['client_order_id'] == new_timestamp
      end
      false
    })

    @wsclient.get_active_spot_orders(callback: hash3[:callback])
    sleep(3)
    assert(hash3[:msg] == '', hash3[:msg])
    @wsclient.cancel_spot_order(client_order_id: new_timestamp, callback: hash[:callback])
    sleep(3)
    assert(hash[:msg] == '', hash[:msg])
  end

  def test_cancel_spot_orders # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
    @wsclient.cancel_spot_orders
    symbol = 'EOSETH'
    @wsclient.create_spot_order(
      client_order_id: Time.now.to_i.to_s,
      symbol: symbol,
      side: 'sell',
      price: '10000',
      quantity: '0.01',
      callback: proc do |error, _report|
        unless error.nil?
          puts error
          return
        end
      end
    )
    sleep(3)
    @wsclient.create_spot_order(
      client_order_id: Time.now.to_i.to_s,
      symbol: symbol,
      side: 'sell',
      price: '10000',
      quantity: '0.01',
      callback: proc do |error, _report|
        unless error.nil?
          puts error
          return
        end
      end
    )
    sleep(3)
    @wsclient.get_active_spot_orders(callback: proc do |error, _order_list|
      unless error.nil?
        puts error
        return
      end
      puts 'wrong number of orders' if orderList.length != 2
    end)
    sleep(3)
    @wsclient.cancel_spot_orders
    sleep(3)
    @wsclient.get_active_spot_orders(callback: proc do |error, _order_list|
      unless error.nil?
        puts error
        return
      end
      if orderList.nil?
        puts 'nil order list'
        return
      end
      puts 'wrong number of orders' unless orderList.empty?
    end)
  end

  def test_get_spot_commissions
    hash = gen_list_checker_callback(->(commission) { good_trading_commission(commission) })
    @wsclient.get_spot_commissions(callback: hash[:callback])
    sleep(3)
    assert(hash[:msg] == '', hash[:msg])
  end

  def test_get_spot_commission
    hash = gen_checker_callback(->(commission) { good_trading_commission(commission) })
    @wsclient.get_spot_commission(symbol: 'EOS', callback: hash[:callback])
    sleep(3)
    assert(hash[:msg] == '', hash[:msg])
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
      callback: proc do |error, result|
        unless error.nil?
          puts error
          return
        end
        puts result
      end
    )
    sleep(5)
  end
end
