# frozen_string_literal: true

require 'test/unit'
require_relative '../key_loader'
require_relative '../checks'
require_relative '../../lib/cryptomarket/client'

class ChangeWindow < Test::Unit::TestCase # rubocop:disable Style/Documentation
  def setup
    @client = Cryptomarket::Client.new api_key: KeyLoader.api_key, api_secret: KeyLoader.api_secret
  end

  def test_change_window
    result = @client.get_wallet_balances
    assert(good_list(->(balance) { Check.good_balance(balance) }, result))

    @client.change_window window: 100
    begin
      @client.get_wallet_balances
      assert(false)
    rescue Cryptomarket::APIException
      nil
    end

    @client.change_window window: 10_000
    result = @client.get_wallet_balances
    assert(good_list(->(balance) { Check.good_balance(balance) }, result))
  end
end
