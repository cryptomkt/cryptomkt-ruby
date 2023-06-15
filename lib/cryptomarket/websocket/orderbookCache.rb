require "bigdecimal"

module Cryptomarket
    module Websocket
        class OrderbookCache 

            # orderbook states
            @@UPDATING = 0
            @@WAITING = 1
            @@BROKEN = 2
            # order book side ordering direction
            @@ASCENDING = 3
            @@DESCENDING = 4

            def initialize() 
                @orderbooks = Hash.new
                @orderbooks_states = Hash.new
            end

            def update(method, key, update_data) 
                case method
                when 'snapshotOrderbook'
                    @orderbooks_states[key] = @@UPDATING
                    @orderbooks[key] = update_data
                    return @orderbooks[key]
                when 'updateOrderbook'
                    if @orderbooks_states[key] != @@UPDATING
                        return
                    end
                    old_orderbook = @orderbooks[key]
                    if update_data['sequence'] - old_orderbook['sequence'] != 1
                        @orderbooks_states[key] = @@BROKEN
                        return
                    end
                    old_orderbook['sequence'] = update_data['sequence']
                    old_orderbook['timestamp'] = update_data['timestamp']
                    if update_data.has_key? 'ask'
                        old_orderbook['ask'] = update_book_side(old_orderbook['ask'], update_data['ask'], @@ASCENDING)
                    end
                    if update_data.has_key? 'bid'
                        old_orderbook['bid'] = update_book_side(old_orderbook['bid'], update_data['bid'], @@DESCENDING)
                    end
                end
            end

            def update_book_side(old_list, update_list, sort_direction) 
                new_list = Array.new
                old_idx = 0
                update_idx = 0
                while (old_idx < old_list.length && update_idx < update_list.length) 
                    update_entry = update_list[update_idx]
                    old_entry = old_list[old_idx]
                    order = price_ordering(old_entry, update_entry, sort_direction)
                    if (order == 0) 
                        if not is_zero_size(update_entry)
                            new_list.push(update_entry)
                        end
                        update_idx+= 1
                        old_idx+= 1
                    elsif (order == 1)
                        new_list.push(old_entry)
                        old_idx+= 1
                    else 
                        new_list.push(update_entry)
                        update_idx+= 1
                    end
                end
                if update_idx == update_list.length
                    for idx in old_idx..old_list.length-1
                        old_entry = old_list[idx]
                        new_list.push(old_entry)
                    end
                end
                if (old_idx == old_list.length)
                    for idx in update_idx..update_list.length-1
                        update_entry = update_list[idx]
                        if not is_zero_size(update_entry)
                            new_list.push(update_entry)
                        end
                    end
                end 
                return new_list
            end

            def is_zero_size(entry) 
                size = BigDecimal(entry['size'])
                return size == BigDecimal("0.00")
            end
            
            def price_ordering(old_entry, update_entry, sort_direction) 
                old_price = BigDecimal(old_entry['price'])
                update_price = BigDecimal(update_entry['price'])
                direction = 1
                if old_price > update_price
                    direction = -1
                end
                if old_price == update_price
                    direction = 0
                end
                if sort_direction == @@ASCENDING
                    return direction
                end
                return -direction
            end

            def getOrderbook(key)
                return Marshal.load(Marshal.dump(@orderbooks[key]))
            end

            def orderbookBroken(key)
                return @orderbooks_states[key] == @@BROKEN
            end
            def orderbookWating(key)
                return @orderbooks_states[key] == @@WAITING
            end

            def waitOrderbook(key)
                @orderbooks_states[key] = @@WAITING
            end
        end
    end
end