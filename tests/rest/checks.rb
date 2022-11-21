require "bigdecimal"

# defined checks if a key is present in a dict, and if its value is str, checks if its defined.
# return false when the key is not present or when the value is an empty string, return true otherwise.
def defined(aHash, key)
    if not aHash.key? key
        return false
    end
    val = aHash[key]
    if val.nil?
        return false
    end
    return true
end

# goodParams checks all of the values in the fields list to be present in the dict, and if they are
# present, check the defined() condition to be true. if any of the fields fails to be defined(), then
# this def returns false
def goodParams(aHash, fields)
    if aHash.nil?
        return false
    end
    fields.each {|field|
        if not defined(aHash, field)
            return false
        end
    }
    return true
end

def goodList(checkFn, list)
  list.each{|elem|
    if not checkFn.(elem)
      return false
    end
  }
  return true
end

def goodHash(checkFn, hash)
  hash.each{|key, elem|
    if not checkFn(elem)
      return false
    end
  }
  return true
end


# goodCurrency checks the precence of every field in the currency dict
def goodCurrency(currency)
    good = goodParams(currency,
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
    return goodParams(network,
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
    return goodParams(symbol,
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
    return goodParams(ticker,
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
    return goodParams(price,
        [
            "currency",
            "price",
            "timestamp",
        ]
    )
end

# goodTicker check the precence of every field in the ticker dict
def goodPriceHistory(priceHistory)
    good = goodParams(priceHistory,
        [
            "currency",
            "history",
        ]
    )
    if not good
        return false
    end
    for point in priceHistory["history"]
        if not goodHistoryPoint(point)
            return false
        end
    end
    return true
end

# goodTicker check the precence of every field in the ticker dict
def goodHistoryPoint(point)
    return goodParams(point,
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
    return goodParams(price,
        [
            "price",
            "timestamp",
        ]
    )
end



# goodPublicTrade check the precence of every field in the trade dict
def goodPublicTrade(trade)
    return goodParams(trade,
        [
            "id",
            "price",
            "qty",
            "side",
            "timestamp",
        ]
    )
end

# goodOrderbookLevel check the precence of every field in the level dict
def goodOrderbookLevel(level)
    return level.length() == 2
end

# goodOrderbook check the precence of every field in the orderbook dict
# and the fields of each level in each side of the orderbook
def goodOrderbook(orderbook)
    goodOrderbook = goodParams(orderbook,
        [
            "timestamp",
            # "batchingTime",
            "ask",
            "bid",
        ]
    )
    if not goodOrderbook
        return false
    end

    orderbook["ask"].each {|level|
        if not goodOrderbookLevel(level)
            return false
        end
    }
    orderbook["bid"].each {|level|
        if not goodOrderbookLevel(level)
            return false
        end
    }
    return true
end


# goodCandle check the precence of every field in the candle dict
def goodCandle(candle)
    return goodParams(candle,
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
    return goodParams(balance,
        [
            "currency",
            "available",
            "reserved",
        ]
    )
end

# goodOrder check the precence of every field in the order dict
def goodOrder(order)
    return goodParams(order,
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
    return goodParams(trade,
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
    good = goodParams(transaction,
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
      if not goodNativeTransaction(transaction["native"])
        return false
      end
    end
    if transaction.key? "meta"
      if not goodMetaTransaction(transaction["meta"])
        return false
      end
    end
    return true
end

def goodNativeTransaction(nativeTransaction)
  return goodParams(nativeTransaction,
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

def goodMetaTransaction(metaTransaction)
  return goodParams(metaTransaction,
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
  return goodParams(address,
    [
      "currency",
      "address",
      # "payment_ids", # optional
      # "public_key", # optional
    ]
  )
end


def goodTradingCommission(commission)
  return goodParams(commission,
    [
      "symbol",
      "make_rate",
      "take_rate"
    ]
  )
end

