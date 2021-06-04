module Cryptomarket
    module Utils
        def extend_hash_with_pagination!(hash, sort: nil, by:nil, from: nil, till: nil, limit: nil, offset: nil)
            if not sort.nil?
                hash['sort'] = sort
            end
            if not by.nil?
                hash['by'] = by
            end
            if not from.nil?
                hash['from'] = from
            end
            if not till.nil?
                hash['till'] = till
            end
            if not limit.nil?
                hash['limit'] = limit
            end
            if not offset.nil?
                hash['offset'] = offset
            end
        end

        def extend_hash_with_order_params! hash, symbol:nil, side:nil, quantity:nil, type:nil, timeInForce:nil, price:nil, stopPrice:nil, expireTime:nil, strictValidate:nil, postOnly:nil
            if not symbol.nil?
                hash['symbol'] = symbol
            end
            if not side.nil?
                hash['side'] = side
            end
            if not quantity.nil?
                hash['quantity'] = quantity
            end
            if not type.nil?
                hash['type'] = type
            end
            if not timeInForce.nil?
                hash['timeInForce'] = timeInForce
            end
            if not price.nil?
                hash['price'] = price
            end
            if not stopPrice.nil?
                hash['stopPrice'] = stopPrice
            end
            if not expireTime.nil?
                hash['expireTime'] = expireTime
            end
            if not strictValidate.nil?
                hash['strictValidate'] = strictValidate
            end
            if not postOnly.nil?
                hash['postOnly'] = postOnly
            end
        end
    end
end