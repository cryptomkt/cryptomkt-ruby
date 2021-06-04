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

            def update(method, key, updateData) 
                case method
                when 'snapshotOrderbook'
                    @orderbooks_states[key] = @@UPDATING
                    @orderbooks[key] = updateData
                    return @orderbooks[key]
                when 'updateOrderbook'
                    if @orderbooks_states[key] != @@UPDATING
                        return
                    end
                    oldOrderbook = @orderbooks[key]
                    if updateData['sequence'] - oldOrderbook['sequence'] != 1
                        @orderbooks_states[key] = @@BROKEN
                        return
                    end
                    oldOrderbook['sequence'] = updateData['sequence']
                    oldOrderbook['timestamp'] = updateData['timestamp']
                    if updateData.has_key? 'ask'
                        oldOrderbook['ask'] = updateBookSide(oldOrderbook['ask'], updateData['ask'], @@ASCENDING)
                    end
                    if updateData.has_key? 'bid'
                        oldOrderbook['bid'] = updateBookSide(oldOrderbook['bid'], updateData['bid'], @@DESCENDING)
                    end
                end
            end

            def updateBookSide(oldList, updateList, sortDirection) 
                newList = Array.new
                oldIdx = 0
                updateIdx = 0
                while (oldIdx < oldList.length && updateIdx < updateList.length) 
                    updateEntry = updateList[updateIdx]
                    oldEntry = oldList[oldIdx]
                    order = priceOrder(oldEntry, updateEntry, sortDirection)
                    if (order == 0) 
                        if not zeroSize(updateEntry)
                            newList.push(updateEntry)
                        end
                        updateIdx+= 1
                        oldIdx+= 1
                    elsif (order == 1)
                        newList.push(oldEntry)
                        oldIdx+= 1
                    else 
                        newList.push(updateEntry)
                        updateIdx+= 1
                    end
                end
                if updateIdx == updateList.length
                    for idx in oldIdx..oldList.length-1
                        oldEntry = oldList[idx]
                        newList.push(oldEntry)
                    end
                end
                if (oldIdx == oldList.length)
                    for idx in updateIdx..updateList.length-1
                        updateEntry = updateList[idx]
                        if not zeroSize(updateEntry)
                            newList.push(updateEntry)
                        end
                    end
                end 
                return newList
            end

            def zeroSize(entry) 
                size = BigDecimal(entry['size'])
                return size == BigDecimal("0.00")
            end
            
            def priceOrder(oldEntry, updateEntry, sortDirection) 
                oldPrice = BigDecimal(oldEntry['price'])
                updatePrice = BigDecimal(updateEntry['price'])
                # puts oldEntry.to_s() +"\t" + updateEntry.to_s()
                direction = 1
                if oldPrice > updatePrice
                    direction = -1
                end
                if oldPrice == updatePrice
                    direction = 0
                end
                if sortDirection == @@ASCENDING
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