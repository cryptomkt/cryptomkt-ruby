require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/wallet_client'
require_relative '../../lib/cryptomarket/client'
require_relative '../key_loader'
require_relative '../checks'

class TestWSaccount < Test::Unit::TestCase
  def setup
    @wsclient = Cryptomarket::Websocket::WalletClient.new api_key: Keyloader.api_key, api_secret: Keyloader.api_secret
    @wsclient.connect
    @restclient = Cryptomarket::Client.new api_key: Keyloader.api_key, api_secret: Keyloader.api_secret
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def test_transaction_subscription
    msg = ''
    callback = proc { |notification, _type|
      print notification
      unless goodTransaction(notification)
        msg = 'bad transaction'
        return
      end
    }

    @wsclient.subscribe_to_transactions(callback: callback)
    sleep(3)
    @restclient.transfer_between_wallet_and_exchange(
      currency: 'EOS',
      amount: '0.1',
      source: 'wallet',
      destination: 'spot'
    )
    sleep(3)
    @wsclient.subscribe_to_wallet_balance(callback: proc { |feed, _type|
      print feed
    })
    sleep(3)
    @restclient.transfer_between_wallet_and_exchange(
      currency: 'EOS',
      amount: '0.1',
      source: 'spot',
      destination: 'wallet'
    )
    sleep(3)
    @wsclient.unsubscribe_to_transactions
    assert(msg == '', msg)
  end

  def test_balance_subscription
    msg = ''
    callback = proc { |notification, _type|
      print notification
      # if not goodBalances(notification)
      #     msg = "bad balances"
      #     return
      # end
    }
    @wsclient.subscribe_to_wallet_balance(callback: callback)
    sleep(3)
    @wsclient.unsubscribe_to_wallet_balance
  end
end
