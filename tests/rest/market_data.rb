# frozen_string_literal: true

require 'test/unit'
require_relative '../../lib/cryptomarket/client'
require_relative '../checks'

class TestMarketDataMethods < Test::Unit::TestCase # rubocop:disable Style/Documentation,Metrics/ClassLength
  def setup
    @client = Cryptomarket::Client.new
  end

  def test_get_currencies
    result = @client.get_currencies currencies: nil
    result.each_value { |val| assert(Check.good_currency(val)) }
  end

  def test_get_2_currencies
    result = @client.get_currencies currencies: %w[EOS CRO]
    result.each_value { |val| assert(Check.good_currency(val)) }
  end

  def test_get_currency
    result = @client.get_currency currency: 'USDT'
    assert(Check.good_currency(result))
  end

  def test_get_symbols
    result = @client.get_symbols
    result.each_value { |val| assert(Check.good_symbol(val)) }
  end

  def test_get_2_symbols
    result = @client.get_symbols symbols: %w[XLMETH PAXGUSD]
    result.each_value { |val| assert(Check.good_symbol(val)) }
  end

  def test_get_symbol
    result = @client.get_symbol symbol: 'CROETH'
    assert(Check.good_symbol(result))
  end

  def test_get_tickers
    result = @client.get_tickers

    result.each_value do |val|
      assert(Check.good_ticker(val))
    end
  end

  def test_get_2_tickers
    result = @client.get_tickers symbols: %w[XLMETH PAXGUSD]
    result.each_value { |val| assert(Check.good_ticker(val)) }
  end

  def test_get_ticker
    result = @client.get_ticker symbol: 'XLMETH'
    assert(Check.good_ticker(result))
  end

  def test_get_all_prices
    result = @client.get_prices to: 'ETH'
    assert(false, 'wrong number of ticker prices') if result.length < 2
    result.each_value { |val| assert(Check.good_price(val)) }
  end

  def test_get_a_price
    result = @client.get_prices(to: 'XLM', from: 'ETH')
    assert(false, 'wrong number of ticker prices') if result.length != 1
    result.each_value { |val| assert(Check.good_price(val)) }
  end

  def test_get_price_history
    result = @client.get_price_history to: 'XLM'
    result.each_value { |val| assert(Check.good_price_history(val)) }
  end

  def test_get_ticker_prices
    result = @client.get_ticker_prices symbols: %w[PAXGUSDT ETHBTC]
    assert(false, 'wrong number of ticker prices') if result.length != 2
    result.each_value { |val| assert(Check.good_ticker_price(val)) }
  end

  def test_get_ticker_price
    result = @client.get_ticker_price symbol: 'PAXGUSDT'
    assert(Check.good_ticker_price(result))
  end

  def test_get_trades
    result = @client.get_trades(symbols: %w[XLMETH EOSETH], limit: 5)
    result.each_value do |trades|
      trades.each { |val| assert(Check.good_public_trade(val)) }
    end
  end

  def test_get_trades_by_symbol
    result = @client.get_trades_by_symbol(symbol: 'USDTDAI', limit: 5, offset: 10)
    result.each { |val| assert(Check.good_public_trade(val)) }
  end

  def test_get_orderbooks
    result = @client.get_orderbooks(symbols: %w[EOSETH XLMETH])
    result.each_value do |val|
      assert(Check.good_orderbook(val))
    end
  end

  def test_get_orderbook
    result = @client.get_orderbook(symbol: 'EOSETH')
    assert(Check.good_orderbook(result))
  end

  def test_get_orderbook_volume
    result = @client.get_orderbook_volume(symbol: 'EOSETH', volume: '100')
    assert(Check.good_orderbook(result))
  end

  def test_get_candles
    result = @client.get_candles(symbols: ['EOSETH'], limit: 2)
    result.each_value do |candles|
      candles.each { |val| assert(Check.good_candle(val)) }
    end
  end

  def test_get_candles_by_symbol
    result = @client.get_candles_by_symbol(symbol: 'EOSETH', limit: 2)
    result.each do |candle|
      assert(Check.good_candle(candle))
    end
  end

  def test_get_converted_candles
    symbols = %w[EOSETH BTCUSDT]
    result = @client.get_converted_candles(symbols: symbols, limit: 2, target_currency: 'usdt')
    result['data'].each do |symbol, candles|
      assert(symbols.include?(symbol))
      candles.each { |val| assert(Check.good_candle(val)) }
    end
  end
end
