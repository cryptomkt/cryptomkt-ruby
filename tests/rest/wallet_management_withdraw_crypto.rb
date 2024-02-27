# frozen_string_literal: true

require 'test/unit'
require_relative '../key_loader'
require_relative '../wallet'
require_relative '../checks'
require_relative '../../lib/cryptomarket/client'

class TestRestTradingMethods < Test::Unit::TestCase # rubocop:disable Style/Documentation
  def setup
    @wallet = Wallet.new
    @client = Cryptomarket::Client.new api_key: KeyLoader.api_key, api_secret: KeyLoader.api_secret
  end

  def test_withdraw_crypto_commit
    transaction_id = @client.withdraw_crypto(
      currency: 'ETH',
      amount: '0.00001',
      address: @wallet.eth,
      auto_commit: false
    )
    success = @client.withdraw_crypto_commit id: transaction_id
    assert(success)
  end

  def test_withdraw_crypto_rollback
    transaction_id = @client.withdraw_crypto(
      currency: 'ETH',
      amount: '0.00001',
      address: @wallet.eth,
      auto_commit: false
    )
    success = @client.withdraw_crypto_rollback id: transaction_id
    assert(success)
  end
end
