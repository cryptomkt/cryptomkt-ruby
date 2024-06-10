# frozen_string_literal: true

require 'test/unit'
require_relative '../key_loader'
require_relative '../checks'
require_relative '../../lib/cryptomarket/client'

class TestRestTradingMethods < Test::Unit::TestCase # rubocop:disable Style/Documentation
  def setup
    @client = Cryptomarket::Client.new api_key: KeyLoader.api_key, api_secret: KeyLoader.api_secret
  end

  def test_get_wallet_balances
    result = @client.get_wallet_balances
    assert(good_list(->(balance) { Check.good_balance(balance) }, result))
  end

  def test_get_wallet_balance
    result = @client.get_wallet_balance currency: 'EOS'
    assert(good_params(result, %w[reserved available]))
  end

  def test_get_deposit_crypto_addresses
    result = @client.get_deposit_crypto_addresses
    assert(good_list(->(address) { Check.good_address(address) }, result))
  end

  def test_get_deposit_crypto_address
    result = @client.get_deposit_crypto_address currency: 'ADA'
    assert(Check.good_address(result))
  end

  def test_create_deposit_crypto_address
    result = @client.create_deposit_crypto_address currency: 'ADA'
    assert(Check.good_address(result))
  end

  def test_get_last_10_deposit_crypto_addresses
    result = @client.get_last_10_deposit_crypto_addresses currency: 'ADA'
    assert(good_list(->(address) { Check.good_address(address) }, result))
  end

  def test_get_last_10_withdrawal_crypto_addresses
    result = @client.get_last_10_withdrawal_crypto_addresses currency: 'CLP'
    assert(good_list(->(address) { Check.good_address(address) }, result))
  end

  def test_get_estimate_withdrawal_fees
    result = @client.get_estimate_withdrawal_fees [{ currency: 'ETH', amount: '12' }, { currency: 'BTC', amount: '1' }]
    assert(result.count == 2)
  end

  def test_get_bulk_estimate_withdrawal_fees
    result = @client.get_bulk_estimate_withdrawal_fees fee_requests: [{ currency: 'ETH', amount: '12' },
                                                                      { currency: 'BTC', amount: '1' }]
    assert(result.count == 2)
  end

  def test_get_estimate_withdrawal_fee
    result = @client.get_estimate_withdrawal_fee currency: 'XLM', amount: '3'
    assert(!result.empty?)
  end

  def test_get_bulk_estimate_deposit_fees
    result = @client.get_bulk_estimate_deposit_fees fee_requests: [{ currency: 'ETH', amount: '12' },
                                                                   { currency: 'BTC', amount: '1' }]
    assert(result.count == 2)
  end

  def test_get_estimate_deposit_fee
    result = @client.get_estimate_deposit_fee currency: 'XLM', amount: '3'
    assert(!result.empty?)
  end

  def test_crypto_address_belongs_to_current_account
    ada_address = @client.get_deposit_crypto_address(currency: 'ADA')['address']
    it_belongs = @client.crypto_address_belongs_to_current_account? address: ada_address
    assert(it_belongs)
  end

  def test_transfer_between_wallet_and_exchange # rubocop:disable Metrics/MethodLength
    result = @client.transfer_between_wallet_and_exchange(
      currency: 'CRO',
      amount: '0.1',
      source: 'wallet',
      destination: 'spot'
    )
    assert(!result.empty?)
    result = @client.transfer_between_wallet_and_exchange(
      currency: 'CRO',
      amount: '0.1',
      source: 'spot',
      destination: 'wallet'
    )
    assert(!result.empty?)
  end

  def test_get_transaction_history
    result = @client.get_transaction_history
    assert(good_list(
             ->(transaction) do Check.good_transaction(transaction) end,
             result
           ))
  end

  def test_get_transaction
    transaction_list = @client.get_transaction_history
    first_transaction_id = transaction_list[0]['native']['tx_id']
    result = @client.get_transaction id: first_transaction_id
    assert(Check.good_transaction(result))
  end

  def test_offchain_available
    eos_address = @client.get_deposit_crypto_address(currency: 'EOS')['address']
    result = @client.offchain_available?(
      currency: 'EOS',
      address: eos_address
    )
    assert(!result.nil?)
  end
end
