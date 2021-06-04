require 'test/unit'
require 'lib/cryptomarket/websocket/tradingClient'
require_relative '../rest/keyloader'
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

    def test_get_balance
        msg = ""
        callback = Proc.new {|error, result| 
            if not error.nil?
                msg = "error"
            end
            result.each {|val| 
                if not goodBalance(val)
                    msg = "bad balance"
                end
            }
        }
        @wsclient.getTradingBalance(callback)
        sleep(3)
        assert(msg == "", msg)
    end
    
    def test_order_work_flow
        msg = ""
        timestamp = Time.now.to_i.to_s
        symbol = 'EOSETH'
        checkValidOrder = Proc.new {|error, result|
            if not error.nil?
                msg = "error"
            end
            if not goodOrder(result)
                msg = "bad order"
            end
        }
        @wsclient.createOrder symbol: symbol, price:'10000', quantity:'0.01', side:'sell', clientOrderId:timestamp, callback: checkValidOrder
        sleep(3)

        assert(msg == "", msg)
        find_our_order = Proc.new {|error, result|
            if not error.nil?
                msg = "error"
            end
            finded = false
            for order in result
                if order['clientOrderId'] == timestamp
                    finded = true
                end
            end
            if not finded
                msg = "order not finded"
            end
        }
        @wsclient.getActiveOrders(find_our_order)
        sleep(3)

        assert(msg == "", msg)
        new_timestamp = Time.now.to_i.to_s
        @wsclient.replaceOrder(clientOrderId:timestamp, requestClientId:new_timestamp, quantity:'0.02', price:'20000', callback:checkValidOrder)
        sleep(3)
        assert(msg == "", msg)
        find_our_new_order = Proc.new {|error, result|
            if not error.nil?
                msg = "error"
            end
            finded = false
            for order in result
                if order['clientOrderId'] == new_timestamp
                    finded = true
                end
            end
            if not finded
                msg = "order not finded"
            end
        }
        @wsclient.getActiveOrders(find_our_new_order)
        sleep(3)
        assert(msg == "", msg)
        @wsclient.cancelOrder(new_timestamp, callback: checkValidOrder)
        sleep(3)
        assert(msg == "", msg)
    end
end