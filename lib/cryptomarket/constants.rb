module Cryptomarket
  module Args
    module Sort
      ASC = 'ASC'
      DESC = 'DESC'
    end


    module Period
      _1_MINS = 'M1'
      _3_MINS = 'M3'
      _5_MINS = 'M5'
      _15_MINS = 'M15'
      _30_MINS = 'M30'
      _1_HOURS = 'H1'
      _4_HOURS = 'H4'
      _1_DAYS = 'D1'
      _7_DAYS = 'D7'
      _1_MONTHS = '1M'
    end


    module Side
      BUY = 'buy'
      SELL = 'sell'
    end


    module OrderType
      LIMIT = 'limit'
      MARKET = 'market'
      STOP_LIMIT = 'stopLimit'
      STOP_MARKET = 'stopMarket'
      TAKE_PROFIT_LIMIT = 'takeProfitLimit'
      TAKE_PROFIT_MARKET = 'takeProfitMarket'
    end


    module TimeInForce
      GTC = 'GTC'  # Good till canceled
      IOC = 'IOC'  # Immediate or cancell
      FOK = 'FOK'  # Fill or kill
      DAY = 'Day'  # Good for the day
      GTD = 'GDT'  # Good till date
    end


    module IdentifyBy
      USERNAME = 'username',
      EMAIL = 'email'
    end


    module Offchain
      NEVER = 'never'
      OPTIONALLY = 'optionally'
      REQUIRED = 'required'
    end


    module Account
      SPOT = 'spot',
      WALLET = 'wallet'
    end


    module TransactionType
      DEPOSIT = 'DEPOSIT'
      WITHDRAW = 'WITHDRAW'
      TRANSFER = 'TRANSFER'
      SAWAP = 'SAWAP'
    end


    module TransactionSubtype
      UNCLASSIFIED = 'UNCLASSIFIED'
      BLOCKCHAIN = 'BLOCKCHAIN'
      AIRDROP = 'AIRDROP'
      AFFILIATE = 'AFFILIATE'
      STAKING = 'STAKING'
      BUY_CRYPTO = 'BUY_CRYPTO'
      OFFCHAIN = 'OFFCHAIN'
      FIAT = 'FIAT'
      SUB_ACCOUNT = 'SUB_ACCOUNT'
      WALLET_TO_SPOT = 'WALLET_TO_SPOT'
      SPOT_TO_WALLET = 'SPOT_TO_WALLET'
      WALLET_TO_DERIVATIVES = 'WALLET_TO_DERIVATIVES'
      DERIVATIVES_TO_WALLET = 'DERIVATIVES_TO_WALLET'
      CHAIN_SWITCH_FROM = 'CHAIN_SWITCH_FROM'
      CHAIN_SWITCH_TO = 'CHAIN_SWITCH_TO'
      INSTANT_EXCHANGE = 'INSTANT_EXCHANGE'
    end


    module TransactionStatus
      CREATED = 'CREATED'
      PENDING = 'PENDING'
      FAILED = 'FAILED'
      SUCCESS = 'SUCCESS'
      ROLLED_BACK = 'ROLLED_BACK'
    end


    module SortBy
      CREATED_AT = 'created_at'
      ID = 'id'
    end

    module Contingency
      ALL_OR_NONE = 'allOrNone'
      AON = 'allOrNone'
      ONE_CANCEL_OTHER = 'oneCancelOther'
      OCO = 'oneCancelOther'
      ONE_TRIGGER_ONE_CANCEL_OTHER = 'oneTriggerOneCancelOther'
      OTOCO = 'oneTriggerOneCancelOther'
    end

    module NotificationType
      SNAPSHOT = 'snapshot'
      UPDATE = 'update'
      DATA = 'data'
      COMMAND = 'command'
    end
  end
end