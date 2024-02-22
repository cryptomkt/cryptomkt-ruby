# frozen_string_literal: true

require 'bigdecimal'

# defined checks if a key is present in a dict, and if its value is str, checks if its defined.
# return false when the key is not present or when the value is an empty string, return true otherwise.
def defined(a_hash, key)
  return false unless a_hash.key? key

  val = a_hash[key]
  return false if val.nil?

  true
end

# good_params checks all of the values in the fields list to be present in the dict, and if they are
# present, check the defined() condition to be true. if any of the fields fails to be defined(), then
# this def returns false
def good_params(a_hash, fields)
  return false if a_hash.nil?

  fields.each { |field| return false unless defined(a_hash, field) }
  true
end

def good_orderbook_level(level)
  level.length == 2
end

module Check # rubocop:disable Style/Documentation
  def self.good_currency(currency)
    good = good_params(currency, %w[
                         full_name payin_enabled payout_enabled transfer_enabled
                         precision_transfer networks
                       ])
    return false unless good

    currency['networks'].each { |level| return false unless good_network(level) }
    true
  end

  def self.good_network(network)
    good_params(network,
                %w[
                  network default payin_enabled payout_enabled precision_payout
                  payout_fee payout_is_payment_id payin_payment_id payin_confirmations
                ])
  end

  def self.good_symbol(symbol)
    good_params(symbol,
                %w[
                  type base_currency quote_currency status quantity_increment
                  tick_size take_rate make_rate fee_currency
                ])
  end

  def self.good_ticker(ticker)
    good_params(ticker, %w[low high volume volume_quote timestamp])
  end

  def self.good_price(price)
    good_params(price, %w[currency price timestamp])
  end

  def self.good_price_history(price_history)
    good = good_params(price_history, %w[currency history])
    return false unless good

    price_history['history'].each { |point| return false unless good_history_point(point) }
    true
  end

  def self.good_history_point(point)
    good_params(point, %w[open close min max timestamp])
  end

  def self.good_ticker_price(price)
    good_params(price, %w[price timestamp])
  end

  def self.good_public_trade(trade)
    good_params(trade, %w[id price qty side timestamp])
  end

  def self.good_orderbook(orderbook)
    good_orderbook = good_params(orderbook, %w[timestamp ask bid])
    return false unless good_orderbook

    orderbook['ask'].each { |level| return false unless good_orderbook_level(level) }
    orderbook['bid'].each { |level| return false unless good_orderbook_level(level) }
    true
  end

  def self.good_candle(candle)
    good_params(candle, %w[timestamp open close min max volume volume_quote])
  end

  def self.good_balance(balance)
    good_params(balance, %w[currency available reserved])
  end

  def self.good_order(order)
    good_params(order,
                %w[id client_order_id symbol side status type time_in_force
                   quantity price quantity_cumulative created_at updated_at])
  end

  def self.good_trade
    lambda { |trade|
      good_params(trade, %w[id orderId clientOrderId symbol side quantity
                            price fee timestamp])
    }
  end

  def self.good_native_transaction(native_transaction)
    good_params(native_transaction, %w[tx_id index currency amount])
  end

  def self.good_transaction(transaction)
    good = good_params(transaction, %w[id status type subtype created_at updated_at])
    return false unless good

    return false if transaction.key?('native') && !Check.good_native_transaction(transaction['native'])

    true
  end

  def self.good_address(address)
    good_params(address, %w[currency address])
  end

  def self.good_trading_commission(commission)
    good_params(commission, %w[symbol make_rate take_rate])
  end
end

module WSCheck # rubocop:disable Style/Documentation
  def self.good_ws_public_trade
    ->(trade) { good_params(trade, %w[t i p q s]) }
  end

  def self.good_ws_public_candle
    ->(trade) { good_params(trade, %w[t o c h l v q]) }
  end

  def self.good_ws_mini_ticker
    WSCheck.good_ws_public_candle
  end

  def self.good_ticker
    ->(ticker) { good_params(ticker, %w[t o c h l v q p P L]) } # missing a A b B in some responses
  end

  def self.good_orderbook
    lambda { |orderbook|
      return false unless good_params(orderbook, %w[t s a b])

      orderbook['a'].each { |level| return false unless good_orderbook_level(level) }
      orderbook['b'].each { |level| return false unless good_orderbook_level(level) }
      true
    }
  end

  def self.good_orderbook_top
    ->(orderbook_top) { good_params(orderbook_top, %w[t a b A B]) }
  end

  def self.good_price_rate
    ->(price_rate) { good_params(price_rate, %w[t r]) }
  end

  def self.good_report
    lambda { |report|
      good_params(report,
                  %w[id client_order_id symbol side status type time_in_force
                     quantity price quantity_cumulative created_at updated_at])
    }
  end

  def self.good_balance
    ->(balance) { good_params(balance, %w[currency available reserved]) }
  end

  def self.good_commission
    ->(commission) { good_params(commission, %w[symbol take_rate make_rate]) }
  end

  def self.good_transaction
    ->(transaction) { Check.good_transaction(transaction) }
  end

  def self.print
    lambda { |reports|
      puts reports
    }
  end
end
