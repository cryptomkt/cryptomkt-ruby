require 'test/unit'
require_relative 'key_loader'
require_relative 'checks'
require_relative '../../lib/cryptomarket/client'

class TestRestTradingMethods < Test::Unit::TestCase
    def setup
        @client = Cryptomarket::Client.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
    end

    def test_get_wallet_balance
      result = @client.get_wallet_balance
      assert(goodList(
        lambda do |balance| goodBalance(balance) end,
        result
      ))
    end

    def test_get_wallet_balance_of_currency
      result = @client.get_wallet_balance_of_currency currency:"EOS"
      assert(goodParams(result, ["reserved", "available"]))
    end

    def test_get_deposit_crypto_addresses
      result = @client.get_deposit_crypto_addresses
      assert(goodList(
        lambda do |address| goodAddress(address) end,
          result
      ))
    end

    def test_get_deposit_crypto_address_of_currency
      result = @client.get_deposit_crypto_address_of_currency currency:"ADA"
      assert(goodAddress(result))
    end

    def test_create_deposit_crypto_address
      result = @client.create_deposit_crypto_address currency:"ADA"
      assert(goodAddress(result))
    end

    def test_get_last_10_deposit_crypto_addresses
      result = @client.get_last_10_deposit_crypto_addresses currency:"ADA"
      assert(goodList(
        lambda do |address| goodAddress(address) end,
          result
      ))
    end

    def test_get_last_10_withdrawal_crypto_addresses
      result = @client.get_last_10_withdrawal_crypto_addresses currency:"CLP"
      assert(goodList(
        lambda do |address| goodAddress(address) end,
          result
      ))
    end

    def test_withdraw_crypto
      ada_address = @client.get_deposit_crypto_address_of_currency(currency:"ADA")["address"]
      transaction_id = @client.withdraw_crypto(
        currency:"ADA",
        amount:"0.1",
        address:ada_address
      )
      assert(!transaction_id.empty?)
    end

    def test_withdraw_crypto_commit
      ada_address = @client.get_deposit_crypto_address_of_currency(currency:"ADA")["address"]
      transaction_id = @client.withdraw_crypto(
        currency:"ADA",
        amount:"0.1",
        address:ada_address,
        auto_commit:false
      )
      success = @client.withdraw_crypto_commit id:transaction_id
      assert(success)
    end

    def test_withdraw_crypto_rollback
      ada_address = @client.get_deposit_crypto_address_of_currency(currency:"ADA")["address"]
      transaction_id = @client.withdraw_crypto(
        currency:"ADA",
        amount:"0.1",
        address:ada_address,
        auto_commit:false
      )
      success = @client.withdraw_crypto_rollback id:transaction_id
      assert(success)
    end

    def test_get_estimate_withdrawal_fee
      result = @client.get_estimate_withdrawal_fee currency:"XLM", amount:"3"
      assert(!result.empty?)
    end

    def test_convert_between_currencies
      #TODO: not working, responds with error: Action is forbidden for this API key
      # result = @client.convert_between_currencies(
      #   from_currency:"ADA",
      #   to_currency:"XLM",
      #   amount:"0.1",
      # )
      # puts result

      # result = @client.convert_between_currencies(
      #   from_currency:"XLM",
      #   to_currency:"ADA",
      #   amount:"0.1",
      # )
      # puts result
    end

    def test_crypto_address_belongs_to_current_account
      ada_address = @client.get_deposit_crypto_address_of_currency(currency:"ADA")["address"]
      it_belongs = @client.crypto_address_belongs_to_current_account? address: ada_address
      assert(it_belongs)
    end

    def test_transfer_between_wallet_and_exchange
      result = @client.transfer_between_wallet_and_exchange(
        currency: "CRO",
        amount: "0.1",
        source:"wallet",
        destination:"spot",
      )
      assert(!result.empty?)
      result = @client.transfer_between_wallet_and_exchange(
        currency: "CRO",
        amount: "0.1",
        source:"spot",
        destination:"wallet",
      )
      assert(!result.empty?)
    end

    def test_transfer_money_to_another_user
      # Good
      # result = @client.transfer_money_to_another_user(
      #   currency:"CRO",
      #   amount:"0.1",
      #   by:"email",
      #   identifier:"the_email",
      # )
      # puts result
    end

    def test_get_transaction_history
      result = @client.get_transaction_history
      assert(goodList(
        lambda do |transaction| goodTransaction(transaction) end,
          result
      ))
    end

    def test_get_transaction
      # TODO: change it form transaciton["native"]["tx_id"] to transaction["id"], not working as intended
      # transaction_list = @client.get_transaction_history
      # first_transaction_id = transaction_list[0]["native"]["tx_id"]
      # result = @client.get_transaction id: first_transaction_id
      # assert(goodTransaction(result))
    end

    def test_offchain_available
      eos_address = @client.get_deposit_crypto_address_of_currency(currency:"EOS")["address"]
      result = @client.offchain_available?(
        currency:"EOS",
        address:eos_address
      )
      assert(!result.nil?)
    end

    def test_get_airdrops
      # TODO: have airdrops to get
      result = @client.get_airdrops
      # puts result
    end

    def test_cliam_airdrop
      # TODO: have airdrops to claim
    end

    def test_get_amount_locks
      # TODO: have amount locks to get
      result = @client.get_amount_locks
      # puts result
    end
end