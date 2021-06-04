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

# goodHash checks all of the values in the fields list to be present in the dict, and if they are 
# present, check the defined() condition to be true. if any of the fields fails to be defined(), then 
# this def returns false
def goodHash(aHash, fields)
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


# goodCurrency checks the precence of every field in the currency dict
def goodCurrency(currency)
    return goodHash(currency,
        [
            "id",
            "fullName",
            "crypto",
            "payinEnabled",
            "payinPaymentId",
            "payinConfirmations",
            "payoutEnabled",
            "payoutIsPaymentId",
            "transferEnabled",
            "delisted",
            # "precisionPayout",
            # "precisionTransfer",
        ]
    )
end

# goodSymbol check the precence of every field in the symbol dict
def goodSymbol(symbol)
    return goodHash(symbol, 
        [
            'id',
            'baseCurrency',
            'quoteCurrency',
            'quantityIncrement',
            'tickSize',
            'takeLiquidityRate',
            'provideLiquidityRate',
            # 'feeCurrency'
        ]
    )
end


# goodTicker check the precence of every field in the ticker dict
def goodTicker(ticker)
    return goodHash(ticker, 
        [
            "symbol",
            "ask",
            "bid",
            "last",
            "low",
            "high",
            "open",
            "volume",
            "volumeQuote",
            "timestamp",
        ]
    )
end


# goodPublicTrade check the precence of every field in the trade dict
def goodPublicTrade(trade)
    return goodHash(trade, 
        [
            "id",
            "price",
            "quantity",
            "side",
            "timestamp",
        ]
    )
end

# goodOrderbookLevel check the precence of every field in the level dict
def goodOrderbookLevel(level)
    return goodHash(level, 
        [
            "price",
            "size",
        ]
    )
end

# goodOrderbook check the precence of every field in the orderbook dict
# and the fields of each level in each side of the orderbook
def goodOrderbook(orderbook)
    goodOrderbook = goodHash(orderbook, 
        [
            "symbol",
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
    for side in [orderbook['bid'], orderbook['ask']]
        for level in side
            if BigDecimal(level['size']) === BigDecimal('0.00')
                return false
            end
        end
    end
    return true
end


# goodCandle check the precence of every field in the candle dict
def goodCandle(candle)
    return goodHash(candle, 
        [
            "timestamp",
            "open",
            "close",
            "min",
            "max",
            "volume",
            "volumeQuote",
        ]
    )
end

# goodBalances check the precence of every field on every balance dict
def goodBalances(balances)
    balances.each {|balance|
        goodBalance = goodHash(balance, 
            [
                "currency",
                "available",
                "reserved",
            ]
        )
        if not goodBalance 
            return false
        end
    }
    return true
end

def goodBalance(balance)
    return goodHash(balance, 
        [
            "currency",
            "available",
            "reserved",
        ]
    )
end

# goodOrder check the precence of every field in the order dict
def goodOrder(order)
    return goodHash(order, 
        [
            "id",
            "clientOrderId",
            "symbol",
            "side",
            "status",
            "type",
            "timeInForce",
            "quantity",
            "price",
            "cumQuantity",
            # "postOnly", # does not appears in the orders in orders history
            "createdAt",
            "updatedAt",
        ]
    )
end


# goodTrade check the precence of every field in the trade dict
def goodTrade(trade)
    return goodHash(trade, 
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
    return goodHash(transaction, 
        [
            "id",
            "index",
            "currency",
            "amount",
            # "fee",
            # "address",
            # "hash",
            "status",
            "type",
            "createdAt",
            "updatedAt",
        ]
    )
end

