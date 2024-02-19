require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/market_data_client'
require_relative '../key_loader'
require_relative '../checks'
require_relative 'sequence_flow'
require_relative 'time_flow'

class TestWSPublicSubs < Test::Unit::TestCase
  @@SECOND = 1
  @@MINUTE = 60
  @@HOUR = 3600
  def setup
    @wsclient = Cryptomarket::Websocket::MarketDataClient.new
    @wsclient.connect
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def gen_result_callback
    proc { |err, result|
      if !err.nil?
        puts err
      else
        puts result
      end
    }
  end

  def gen_print_callback
    proc { |feed, type|
      puts 'notification'
      puts type
      puts feed
    }
  end

  def test_trades_subscription
    puts '***TRADES TEST***'
    @wsclient.subscribe_to_trades(
      callback: gen_print_callback,
      symbols: %w[eoseth ethbtc],
      limit: 2,
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_candles_subscriptions
    puts '***CANDLES TEST***'
    @wsclient.subscribe_to_candles(
      period: 'M1',
      callback: gen_print_callback,
      symbols: %w[eoseth ethbtc],
      limit: 2,
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_mini_ticker
    puts '***MINI TICKER TEST***'
    @wsclient.subscribe_to_mini_ticker(
      speed: '1s',
      callback: gen_print_callback,
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_mini_ticker_in_batches
    puts '***MINI TICKER IN BATCHES TEST***'
    @wsclient.subscribe_to_mini_ticker_in_batches(
      speed: '1s',
      callback: gen_print_callback,
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_ticker
    puts '***TICKER TEST***'
    @wsclient.subscribe_to_ticker(
      speed: '1s',
      callback: gen_print_callback,
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_ticker_in_batches
    puts '***TICKER IN BATCHES TEST***'
    @wsclient.subscribe_to_ticker_in_batches(
      speed: '1s',
      callback: gen_print_callback,
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_full_order_book
    puts '***FULL ORDERBOOK TEST***'
    @wsclient.subscribe_to_full_order_book(
      callback: gen_print_callback,
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_partial_order_book
    puts '***PARTIAL ORDERBOOK TEST***'
    @wsclient.subscribe_to_partial_order_book(
      speed: '100ms',
      depth: 'D5',
      callback: gen_print_callback,
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_partial_order_book_in_batches
    puts '***PARTIAL ORDERBOOK IN BATCHES TEST***'
    @wsclient.subscribe_to_partial_order_book_in_batches(
      speed: '100ms',
      depth: 'D5',
      callback: gen_print_callback,
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_top_of_book
    puts '***TOP OF BOOK TEST***'
    @wsclient.subscribe_to_top_of_book(
      speed: '100ms',
      callback: gen_print_callback,
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_top_of_book_in_batches
    puts '***TOP OF BOOK IN BATCHES TEST***'
    @wsclient.subscribe_to_top_of_book_in_batches(
      speed: '100ms',
      callback: gen_print_callback,
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_price_rates
    puts '***PRICE RATES TEST***'
    @wsclient.subscribe_to_price_rates(
      speed: '1s',
      callback: gen_print_callback,
      target_currency: 'ETH',
      currencies: %w[eos btc],
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end

  def test_subscribe_to_price_rates_in_batches
    puts '***PRICE RATES TEST***'
    @wsclient.subscribe_to_price_rates_in_batches(
      speed: '1s',
      callback: gen_print_callback,
      target_currency: 'ETH',
      currencies: %w[eos btc],
      result_callback: gen_result_callback
    )
    sleep(20 * @@SECOND)
  end
end
