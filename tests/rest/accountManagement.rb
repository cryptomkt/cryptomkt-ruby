require 'test/unit'
require_relative 'keyloader'
require_relative 'checks'
require 'lib/cryptomarket/client'

class TestRestTradingMethods < Test::Unit::TestCase
    def setup
        @client = Cryptomarket::Client.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
    end

    def test_get_account_balance
        result = @client.getAccountBalance
        result.each {|val| assert(goodBalance(val))}
    end
    
    # def test_get_deposit_crypto_address
    #     result = @client.getDepositCryptoAddress 'eos'
    #     puts result
    # end

    # def test_create_deposit_crypto_address
    #     result = @client.createDepositCryptoAddress('EOS')
    #     puts result
    # end

    def test_get_last_10_deposit_crypto_addresses
        result = @client.getLast10DepositCryptoAddresses('EOS')
        # puts result
    end


    def test_get_last_10_used_crypto_addresses
        result = @client.getLast10UsedCryptoAddresses('EOS')
        # puts result
    end

    def test_withdraw_crypto
        # FORBIDDEN
        # cryptoAddress = @client.getDepositCryptoAddress 'eos'
        # result = @client.withdrawCrypto currency:'EOS', amount:'0.01', address:cryptoAddress['address'], paymentId:cryptoAddress['paymentId']
    end

    def test_transfer_convert
        # FORBIDDEN
        # result = @client.transferConvert("EOS", "ETH", "0.01")
        # puts result
    end

    def test_get_estimate_withdraw_fee
        result = @client.getEstimateWithdrawFee "EOS", "100"
        # puts result
    end

    # def test_check_crypto_address_is_mine
    #     result = @client.checkIfCryptoAddressIsMine 'hitbtcpayins'
    #     puts result
    # end

    def test_transfer_balance_between_bank_to_exchange
        balance = @client.getAccountBalance
        eosbalance = nil
        balance.each {|bal| 
            if bal["currency"]=="EOS"
                eosbalance = bal["available"]
            end
        }
        result = @client.transferMoneyFromBankToExchange "EOS", "0.1"
        result = @client.transferMoneyFromExchangeToBank "EOS", "0.1"
        finaleosbalance = nil
        balance.each {|bal| 
            if bal["currency"]=="EOS"
                finaleosbalance = bal["available"]
            end
        }
        assert(eosbalance == finaleosbalance)
    end

    def test_get_transaction_history
        result = @client.getTransactionHistory currency:"EOS"
        result.each {|val| assert(goodTransaction(val))}
    end

    def test_get_transaction_by_id
        result = @client.getTransaction "62bbbc6b-cbef-4999-9c69-f252031dc00b"
        assert(goodTransaction(result))
    end
end