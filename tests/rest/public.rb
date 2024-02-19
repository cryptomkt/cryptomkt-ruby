require 'test/unit'
require_relative '../../lib/cryptomarket/client'
require_relative '../checks'

class TestRestPublicMethods < Test::Unit::TestCase
  def setup
    @client = Cryptomarket::Client.new
  end

  def test_get_currencies
    result = @client.get_currencies currencies: nil
    result.each { |_key, val| assert(goodCurrency(val)) }
  end

  def test_get_2_currencies
    result = @client.get_currencies currencies: %w[EOS CRO]
    result.each { |_key, val| assert(goodCurrency(val)) }
  end

  def test_get_currency
    result = @client.get_currency currency: 'USDT'
    assert(goodCurrency(result))
  end

  def test_get_symbols
    result = @client.get_symbols
    result.each { |_key, val| assert(goodSymbol(val)) }
  end

  def test_get_2_symbols
    result = @client.get_symbols symbols: %w[XLMETH PAXGUSD]
    result.each { |_key, val| assert(goodSymbol(val)) }
  end

  def test_get_symbol
    result = @client.get_symbol symbol: 'CROETH'
    assert(goodSymbol(result))
  end

  def test_get_tickers
    result = @client.get_tickers

    result.each do |_key, val|
      assert(goodTicker(val))
    end
  end

  def test_get_2_tickers
    result = @client.get_tickers symbols: %w[XLMETH PAXGUSD]
    result.each { |_key, val| assert(goodTicker(val)) }
  end

  def test_get_ticker
    result = @client.get_ticker symbol: 'XLMETH'
    assert(goodTicker(result))
  end

  def test_get_all_prices
    result = @client.get_prices to: 'ETH'
    assert(false, 'wrong number of ticker prices') if result.length < 2
    result.each { |_key, val| assert(goodPrice(val)) }
  end

  def test_get_a_price
    result = @client.get_prices(to: 'XLM', from: 'ETH')
    assert(false, 'wrong number of ticker prices') if result.length != 1
    result.each { |_key, val| assert(goodPrice(val)) }
  end

  def test_get_price_history
    result = @client.get_price_history to: 'XLM'
    result.each { |_key, val| assert(goodPriceHistory(val)) }
  end

  def test_get_ticker_price
    result = @client.get_ticker_prices symbols: %w[PAXGUSDT ETHBTC]
    assert(false, 'wrong number of ticker prices') if result.length != 2
    result.each { |_key, val| assert(goodTickerPrice(val)) }
  end

  def test_get_ticker_price_of_symbol
    result = @client.get_ticker_price_of_symbol symbol: 'PAXGUSDT'
    assert(goodTickerPrice(result))
  end

  def test_get_trades
    result = @client.get_trades(symbols: %w[XLMETH EOSETH], limit: 5)
    result.each do |_symbol, trades|
      trades.each { |val| assert(goodPublicTrade(val)) }
    end
  end

  def test_get_trades_of_symbol
    result = @client.get_trades_of_symbol(symbol: 'USDTDAI', limit: 5, offset: 10)
    result.each { |val| assert(goodPublicTrade(val)) }
  end

  def test_get_orderbooks
    result = @client.get_orderbooks(symbols: %w[EOSETH XLMETH])
    result.each do |_key, val|
      assert(good_orderbook(val))
    end
  end

  def test_get_orderbook_of_symbol
    result = @client.get_orderbook_of_symbol(symbol: 'EOSETH')
    assert(good_orderbook(result))
  end

  def test_get_orderbook_volume_of_symbol
    result = @client.get_orderbook_volume_of_symbol(symbol: 'EOSETH', volume: '100')
    assert(good_orderbook(result))
  end

  def test_get_candles
    result = @client.get_candles(symbols: ['EOSETH'], limit: 2)
    result.each do |_key, candles|
      candles.each { |val| assert(goodCandle(val)) }
    end
  end

  def test_get_candles_of_symbol
    result = @client.get_candles_of_symbol(symbol: 'EOSETH', limit: 2)
    result.each do |candle|
      assert(goodCandle(candle))
    end
  end
end
