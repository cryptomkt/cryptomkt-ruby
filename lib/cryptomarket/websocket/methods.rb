module Cryptomarket
  module Websocket
    module Methods
      ORDERBOOK = 'orderbook'.freeze
      REPORTS = 'reports'.freeze
      TICKERS = 'tickers'.freeze
      TRADES = 'trades'.freeze
      CANDLES = 'candles'.freeze
      MAP = {
        'subscribeReports' => REPORTS,
        'unsubscribeReports' => REPORTS,
        'activeOrders' => REPORTS,
        'report' => REPORTS,

        'subscribeTicker' => TICKERS,
        'unsubscribeTicker' => TICKERS,
        'ticker' => TICKERS,

        'subscribeOrderbook' => ORDERBOOK,
        'unsubscribeOrderbook' => ORDERBOOK,
        'snapshotOrderbook' => ORDERBOOK,
        'updateOrderbook' => ORDERBOOK,

        'subscribeTrades' => TRADES,
        'unsubscribeTrades' => TRADES,
        'snapshotTrades' => TRADES,
        'updateTrades' => TRADES,

        'subscribeCandles' => CANDLES,
        'unsubscribeCandles' => CANDLES,
        'snapshotCandles' => CANDLES,
        'updateCandles' => CANDLES
      }.freeze
    end
  end
end
