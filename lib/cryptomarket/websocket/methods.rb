# frozen_string_literal: true

module Cryptomarket
  module Websocket
    module Methods
      ORDERBOOK = 'orderbook'
      REPORTS = 'reports'
      TICKERS = 'tickers'
      TRADES = 'trades'
      CANDLES = 'candles'
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
