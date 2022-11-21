require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/tradingClient'
require_relative '../rest/key_loader'
require_relative '../rest/checks'

class TestWStrading < Test::Unit::TestCase
  def setup
    @wsclient = Cryptomarket::Websocket::TradingClient.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
    @wsclient.connect
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
      end
      result.each {|val|
        if not checker.call(val)
            msg = "bad val: #{val}"
        end
      }
    }
    return {msg:msg, callback:callback}
  end

  def gen_not_list_checker_callback(checker)
    msg = ""
    callback = Proc.new {|error, result|
      if not error.nil?
        msg = error.to_s
      end
      if not checker.call(result)
          msg = "bad val: #{result}"
      end
    }
    return {msg:msg, callback:callback}
  end

  def test_get_spot_trading_balance
    hash = gen_not_list_checker_callback(->(balance) {goodBalance(balance)})
    @wsclient.get_spot_trading_balance(callback:hash[:callback], currency:"EOS")
    sleep(3)
    assert(hash[:msg] == "", hash[:msg])
  end


  def test_get_spot_trading_balances
    hash = gen_checker_callback(->(balance) {
      puts balance
      return goodBalance(balance)
    })
    @wsclient.get_spot_trading_balances(callback:hash[:callback])
    sleep(3)
    assert(hash[:msg] == "", hash[:msg])
  end

  def test_order_work_flow
    timestamp = Time.now.to_i.to_s
    symbol = 'EOSETH'
    hash = gen_not_list_checker_callback(->(order) {goodOrder(order)})
    @wsclient.create_spot_order(
      client_order_id:timestamp,
      symbol: symbol,
      side:'sell',
      price:'10000',
      quantity:'0.01',
      callback: hash[:callback]
    )
    sleep(3)
    assert(hash[:msg] == "", hash[:msg])
    hash2 = gen_not_list_checker_callback(->(result) {
      for order in result
        if order['client_order_id'] == timestamp
          return true
        end
      end
      return false
    })
    @wsclient.get_active_spot_orders(callback:hash2[:callback])
    sleep(3)
    assert(hash2[:msg] == "", hash2[:msg])

    new_timestamp = Time.now.to_i.to_s
    @wsclient.replace_spot_order(
      client_order_id:timestamp,
      new_client_order_id:new_timestamp,
      price:'20000',
      quantity:'0.02',
      callback:hash[:callback]
    )
    sleep(3)
    assert(hash[:msg] == "", hash[:msg])
    hash3 = gen_not_list_checker_callback(->(result) {
      for order in result
        if order['client_order_id'] == new_timestamp
          return true
        end
      end
      return false
    })

    @wsclient.get_active_spot_orders(callback:hash3[:callback])
    sleep(3)
    assert(hash3[:msg] == "", hash3[:msg])
    @wsclient.cancel_spot_order(client_order_id:new_timestamp, callback: hash[:callback])
    sleep(3)
    assert(hash[:msg] == "", hash[:msg])
  end

  def test_cancel_spot_orders
    @wsclient.cancel_spot_orders
    symbol = 'EOSETH'
    @wsclient.create_spot_order(
      client_order_id:Time.now.to_i.to_s,
      symbol: symbol,
      side:'sell',
      price:'10000',
      quantity:'0.01',
      callback:Proc.new{|error, report|
        if not error.nil?
          puts error
          return
        end
      }
    )
    sleep(3)
    @wsclient.create_spot_order(
      client_order_id:Time.now.to_i.to_s,
      symbol: symbol,
      side:'sell',
      price:'10000',
      quantity:'0.01',
      callback:Proc.new{|error, report|
        if not error.nil?
          puts error
          return
        end
      }
    )
    sleep(3)
    @wsclient.get_active_spot_orders(callback:Proc.new{|error, orderList|
      if not error.nil?
        puts error
        return
      end
      if orderList.length != 2
        puts "wrong number of orders"
      end
    })
    sleep(3)
    @wsclient.cancel_spot_orders
    sleep(3)
    @wsclient.get_active_spot_orders(callback:Proc.new{|error, orderList|
      if not error.nil?
        puts error
        return
      end
      if orderList.nil?
        puts "nil order list"
        return
      end
      if orderList.length != 0
        puts "wrong number of orders"
      end
    })
  end

  def test_get_spot_commissions
    hash = gen_checker_callback(->(commission) {goodTradingCommission(commission)})
    @wsclient.get_spot_commissions(callback:hash[:callback])
    sleep(3)
    assert(hash[:msg] == "", hash[:msg])
  end

  def test_get_spot_commission_of_symbol
    hash = gen_not_list_checker_callback(->(commission) {goodTradingCommission(commission)})
    @wsclient.get_spot_commission_of_symbol(symbol:'EOS', callback:hash[:callback])
    sleep(3)
    assert(hash[:msg] == "", hash[:msg])
  end
end