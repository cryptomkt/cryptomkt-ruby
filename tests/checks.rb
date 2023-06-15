require "bigdecimal"

# defined checks if a key is present in a dict, and if its value is str, checks if its defined.
# return false when the key is not present or when the value is an empty string, return true otherwise.
def defined(a_hash, key)
    if not a_hash.key? key
        return false
    end
    val = a_hash[key]
    if val.nil?
        return false
    end
    return true
end

# good_params checks all of the values in the fields list to be present in the dict, and if they are
# present, check the defined() condition to be true. if any of the fields fails to be defined(), then
# this def returns false
def good_params(a_hash, fields)
    if a_hash.nil?
        return false
    end
    fields.each {|field|
        if not defined(a_hash, field)
            return false
        end
    }
    return true
end

def goodList(check_fn, list)
  list.each{|elem|
    if not check_fn.(elem)
      return false
    end
  }
  return true
end

def goodHash(check_fn, hash)
  hash.each{|key, elem|
    if not check_fn(elem)
      return false
    end
  }
  return true
end


# goodCurrency checks the precence of every field in the currency dict
def goodCurrency(currency)
    good = good_params(currency,
        [
            "full_name",
            "payin_enabled",
            "payout_enabled",
            "transfer_enabled",
            "precision_transfer",
            "networks",
        ]
    )
    if not good
        return false
    end

    currency["networks"].each {|level|
        if not goodNetwork(level)
            return false
        end
    }
    return true
end

def goodNetwork(network)
    return good_params(network,
        [
            "network",
            "default",
            "payin_enabled",
            "payout_enabled",
            "precision_payout",
            "payout_fee",
            "payout_is_payment_id",
            "payin_payment_id",
            "payin_confirmations",
        ]
    )
end

# goodSymbol check the precence of every field in the symbol dict
def goodSymbol(symbol)
    return good_params(symbol,
        [
            "type",
            "base_currency",
            "quote_currency",
            "status",
            "quantity_increment",
            "tick_size",
            "take_rate",
            "make_rate",
            "fee_currency",
            # "margin_trading",
            # "max_initial_leverage",
        ]
    )
end


# goodTicker check the precence of every field in the ticker dict
def goodTicker(ticker)
    return good_params(ticker,
        [
            "low",
            "high",
            "volume",
            "volume_quote",
            "timestamp",
        ]
    )
end

# goodTicker check the precence of every field in the ticker dict
def goodPrice(price)
    return good_params(price,
        [
            "currency",
            "price",
            "timestamp",
        ]
    )
end

# goodTicker check the precence of every field in the ticker dict
def goodPriceHistory(price_history)
    good = good_params(price_history,
        [
            "currency",
            "history",
        ]
    )
    if not good
        return false
    end
    for point in price_history["history"]
        if not goodHistoryPoint(point)
            return false
        end
    end
    return true
end

# goodTicker check the precence of every field in the ticker dict
def goodHistoryPoint(point)
    return good_params(point,
        [
            "open",
            "close",
            "min",
            "max",
            "timestamp",
        ]
    )
end


# goodTicker check the precence of every field in the ticker dict
def goodTickerPrice(price)
    return good_params(price,
        [
            "price",
            "timestamp",
        ]
    )
end



# goodPublicTrade check the precence of every field in the trade dict
def goodPublicTrade(trade)
    return good_params(trade,
        [
            "id",
            "price",
            "qty",
            "side",
            "timestamp",
        ]
    )
end

# good_orderbookLevel check the precence of every field in the level dict
def good_orderbookLevel(level)
    return level.length() == 2
end

# good_orderbook check the precence of every field in the orderbook dict
# and the fields of each level in each side of the orderbook
def good_orderbook(orderbook)
    good_orderbook = good_params(orderbook,
        [
            "timestamp",
            # "batchingTime",
            "ask",
            "bid",
        ]
    )
    if not good_orderbook
        return false
    end

    orderbook["ask"].each {|level|
        if not good_orderbookLevel(level)
            return false
        end
    }
    orderbook["bid"].each {|level|
        if not good_orderbookLevel(level)
            return false
        end
    }
    return true
end


# goodCandle check the precence of every field in the candle dict
def goodCandle(candle)
    return good_params(candle,
        [
            "timestamp",
            "open",
            "close",
            "min",
            "max",
            "volume",
            "volume_quote",
        ]
    )
end

def goodBalance(balance)
    return good_params(balance,
        [
            "currency",
            "available",
            "reserved",
        ]
    )
end

# goodOrder check the precence of every field in the order dict
def goodOrder(order)
    return good_params(order,
        [
            "id",
            "client_order_id",
            "symbol",
            "side",
            "status",
            "type",
            "time_in_force",
            "quantity",
            "price",
            "quantity_cumulative",
            "created_at",
            "updated_at",
        ]
    )
end


# goodTrade check the precence of every field in the trade dict
def goodTrade(trade)
    return good_params(trade,
        [
            "id",
            "orderId",
            "clientOrderId",
            "symbol",
            "side",
            "quantity",
            "price",
            "fee",
            "timestamp",
        ]
    )
end



# goodTransaction check the precence of every field in the transaction dict
def goodTransaction(transaction)
    good = good_params(transaction,
      [
        "id",
        "status",
        "type",
        "subtype",
        "created_at",
        "updated_at",
        # "native", # optional
        # "primetrust", # optional
        # "meta" # optional
      ]
    )
    if not good
      return false
    end
    if transaction.key? "native"
      if not good_native_transaction(transaction["native"])
        return false
      end
    end
    if transaction.key? "meta"
      if not good_meta_transaction(transaction["meta"])
        return false
      end
    end
    return true
end

def good_native_transaction(native_transaction)
  return good_params(native_transaction,
    [
      "tx_id",
      "index",
      "currency",
      "amount",
      # "fee", # optional
      # "address", # optional
      # "payment_id", # optional
      # "hash", # optional
      # "offchain_id", # optional
      # "confirmations", # optional
      # "public_comment", # optional
      # "error_code", # optional
      # "senders" # optional
    ]
  )
end

def good_meta_transaction(meta_transaction)
  return good_params(meta_transaction,
    [
      "fiat_to_crypto",
      "id",
      "provider_name",
      "order_type",
      "source_currency",
      "status",
      "created_at",
      "updated_at",
      "deleted_at",
      "payment_method_type"
    ]
  )
end

def goodAddress(address)
  return good_params(address,
    [
      "currency",
      "address",
      # "payment_ids", # optional
      # "public_key", # optional
    ]
  )
end


def goodTradingCommission(commission)
  return good_params(commission,
    [
      "symbol",
      "make_rate",
      "take_rate"
    ]
  )
end

