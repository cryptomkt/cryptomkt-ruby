module Cryptomarket
    module Websocket
        module Methods
            ORDERBOOK = "orderbook"
            REPORTS = "reports"
            TICKERS = "tickers"
            TRADES = "trades"
            CANDLES = "candles"
            MAP = {
                "subscribeReports" => REPORTS,
                "unsubscribeReports" => REPORTS,
                "activeOrders" => REPORTS,
                "report" => REPORTS,

                "subscribeTicker" => TICKERS,
                "unsubscribeTicker" => TICKERS,
                "ticker" => TICKERS,

                "subscribeOrderbook" => ORDERBOOK,
                "unsubscribeOrderbook" => ORDERBOOK,
                "snapshotOrderbook" => ORDERBOOK,
                "updateOrderbook" => ORDERBOOK,

                "subscribeTrades" => TRADES,
                "unsubscribeTrades" => TRADES,
                "snapshotTrades" => TRADES,
                "updateTrades" => TRADES,
                
                "subscribeCandles" => CANDLES,
                "unsubscribeCandles" => CANDLES,
                "snapshotCandles" => CANDLES,
                "updateCandles" => CANDLES
            }

            def mapping(method)
                return MAP[method]
            end

            def orderbookFeed(method)
                return MAP[method] == ORDERBOOK
            end

            def tradesFeed(method)
                return MAP[method] == TRADES
            end

            def candlesFeed(method)
                return MAP[method] == CANDLES
            end

            def reportsFeed(method)
                return MAP[method] == REPORTS
            end
        end
    end
end