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

  fields.each do |field|
    return false unless defined(a_hash, field)
  end
  true
end

def good_list(check_fn, list)
  list.each do |elem|
    return false unless check_fn.call(elem)
  end
  true
end

def good_hash(_check_fn, hash)
  hash.each_value do |elem|
    return false unless check_fn(elem)
  end
  true
end

# goodCurrency checks the precence of every field in the currency dict
def goodCurrency(currency)
  good = good_params(currency,
                     %w[
                       full_name
                       payin_enabled
                       payout_enabled
                       transfer_enabled
                       precision_transfer
                       networks
                     ])
  return false unless good

  currency['networks'].each do |level|
    return false unless goodNetwork(level)
  end
  true
end

def goodNetwork(network)
  good_params(network,
              %w[
                network
                default
                payin_enabled
                payout_enabled
                precision_payout
                payout_fee
                payout_is_payment_id
                payin_payment_id
                payin_confirmations
              ])
end

# goodSymbol check the precence of every field in the symbol dict
def goodSymbol(symbol)
  good_params(symbol,
              %w[
                type
                base_currency
                quote_currency
                status
                quantity_increment
                tick_size
                take_rate
                make_rate
                fee_currency
              ])
end

# goodTicker check the precence of every field in the ticker dict
def good_ticker(ticker)
  good_params(ticker,
              %w[
                low
                high
                volume
                volume_quote
                timestamp
              ])
end

# goodTicker check the precence of every field in the ticker dict
def good_price(price)
  good_params(price,
              %w[
                currency
                price
                timestamp
              ])
end

# goodTicker check the precence of every field in the ticker dict
def good_price_history(price_history)
  good = good_params(price_history,
                     %w[
                       currency
                       history
                     ])
  return false unless good

  price_history['history'].each do |point|
    return false unless good_history_point(point)
  end
  true
end

# goodTicker check the precence of every field in the ticker dict
def good_history_point(point)
  good_params(point,
              %w[
                open
                close
                min
                max
                timestamp
              ])
end

# goodTicker check the precence of every field in the ticker dict
def good_ticker_price(price)
  good_params(price,
              %w[
                price
                timestamp
              ])
end

# goodPublicTrade check the precence of every field in the trade dict
def good_public_trade(trade)
  good_params(trade,
              %w[
                id
                price
                qty
                side
                timestamp
              ])
end

# good_orderbookLevel check the precence of every field in the level dict
def good_orderbook_level(level)
  level.length == 2
end

# good_orderbook check the precence of every field in the orderbook dict
# and the fields of each level in each side of the orderbook
def good_orderbook(orderbook)
  good_orderbook = good_params(orderbook,
                               %w[
                                 timestamp
                                 ask
                                 bid
                               ])
  return false unless good_orderbook

  orderbook['ask'].each do |level|
    return false unless good_orderbook_level(level)
  end
  orderbook['bid'].each do |level|
    return false unless good_orderbook_level(level)
  end
  true
end

# goodCandle check the precence of every field in the candle dict
def good_candle(candle)
  good_params(candle,
              %w[
                timestamp
                open
                close
                min
                max
                volume
                volume_quote
              ])
end

def good_balance(balance)
  good_params(balance,
              %w[
                currency
                available
                reserved
              ])
end

# goodOrder check the precence of every field in the order dict
def goodOrder(order)
  good_params(order,
              %w[
                id
                client_order_id
                symbol
                side
                status
                type
                time_in_force
                quantity
                price
                quantity_cumulative
                created_at
                updated_at
              ])
end

# goodTrade check the precence of every field in the trade dict
def goodTrade(trade)
  good_params(trade,
              %w[
                id
                orderId
                clientOrderId
                symbol
                side
                quantity
                price
                fee
                timestamp
              ])
end

def good_native_transaction(native_transaction)
  good_params(native_transaction,
              %w[
                tx_id
                index
                currency
                amount
              ])
end

# goodTransaction check the precence of every field in the transaction dict
def goodTransaction(transaction)
  good = good_params(transaction,
                     %w[
                       id
                       status
                       type
                       subtype
                       created_at
                       updated_at
                     ])
  return false unless good

  return false if transaction.key?('native') && !good_native_transaction(transaction['native'])

  true
end

def goodAddress(address)
  good_params(address,
              [
                'currency',
                'address'
                # "payment_ids", # optional
                # "public_key", # optional
              ])
end

def goodTradingCommission(commission)
  good_params(commission,
              %w[
                symbol
                make_rate
                take_rate
              ])
end
