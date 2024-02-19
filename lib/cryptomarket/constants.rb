module Cryptomarket
  module Args
    module Sort
      ASC = 'ASC'.freeze
      DESC = 'DESC'.freeze
    end

    module Period
      _1_MINS = 'M1'.freeze
      _3_MINS = 'M3'.freeze
      _5_MINS = 'M5'.freeze
      _15_MINS = 'M15'.freeze
      _30_MINS = 'M30'.freeze
      _1_HOURS = 'H1'.freeze
      _4_HOURS = 'H4'.freeze
      _1_DAYS = 'D1'.freeze
      _7_DAYS = 'D7'.freeze
      _1_MONTHS = '1M'.freeze
    end

    module Side
      BUY = 'buy'.freeze
      SELL = 'sell'.freeze
    end

    module OrderType
      LIMIT = 'limit'.freeze
      MARKET = 'market'.freeze
      STOP_LIMIT = 'stopLimit'.freeze
      STOP_MARKET = 'stopMarket'.freeze
      TAKE_PROFIT_LIMIT = 'takeProfitLimit'.freeze
      TAKE_PROFIT_MARKET = 'takeProfitMarket'.freeze
    end

    module TimeInForce
      GTC = 'GTC'.freeze  # Good till canceled
      IOC = 'IOC'.freeze  # Immediate or cancell
      FOK = 'FOK'.freeze  # Fill or kill
      DAY = 'Day'.freeze  # Good for the day
      GTD = 'GDT'.freeze  # Good till date
    end

    module IdentifyBy
      USERNAME = 'username'.freeze
      EMAIL = 'email'.freeze
    end

    module Offchain
      NEVER = 'never'.freeze
      OPTIONALLY = 'optionally'.freeze
      REQUIRED = 'required'.freeze
    end

    module Account
      SPOT = 'spot'.freeze
      WALLET = 'wallet'.freeze
    end

    module TransactionType
      DEPOSIT = 'DEPOSIT'.freeze
      WITHDRAW = 'WITHDRAW'.freeze
      TRANSFER = 'TRANSFER'.freeze
      SAWAP = 'SAWAP'.freeze
    end

    module TransactionSubtype
      UNCLASSIFIED = 'UNCLASSIFIED'.freeze
      BLOCKCHAIN = 'BLOCKCHAIN'.freeze
      AIRDROP = 'AIRDROP'.freeze
      AFFILIATE = 'AFFILIATE'.freeze
      STAKING = 'STAKING'.freeze
      BUY_CRYPTO = 'BUY_CRYPTO'.freeze
      OFFCHAIN = 'OFFCHAIN'.freeze
      FIAT = 'FIAT'.freeze
      SUB_ACCOUNT = 'SUB_ACCOUNT'.freeze
      WALLET_TO_SPOT = 'WALLET_TO_SPOT'.freeze
      SPOT_TO_WALLET = 'SPOT_TO_WALLET'.freeze
      WALLET_TO_DERIVATIVES = 'WALLET_TO_DERIVATIVES'.freeze
      DERIVATIVES_TO_WALLET = 'DERIVATIVES_TO_WALLET'.freeze
      CHAIN_SWITCH_FROM = 'CHAIN_SWITCH_FROM'.freeze
      CHAIN_SWITCH_TO = 'CHAIN_SWITCH_TO'.freeze
      INSTANT_EXCHANGE = 'INSTANT_EXCHANGE'.freeze
    end

    module TransactionStatus
      CREATED = 'CREATED'.freeze
      PENDING = 'PENDING'.freeze
      FAILED = 'FAILED'.freeze
      SUCCESS = 'SUCCESS'.freeze
      ROLLED_BACK = 'ROLLED_BACK'.freeze
    end

    module SortBy
      CREATED_AT = 'created_at'.freeze
      ID = 'id'.freeze
    end

    module Contingency
      ALL_OR_NONE = 'allOrNone'.freeze
      AON = 'allOrNone'.freeze
      ONE_CANCEL_OTHER = 'oneCancelOther'.freeze
      OCO = 'oneCancelOther'.freeze
      ONE_TRIGGER_OTHER = 'oneTriggerOther'.freeze
      OTO = 'oneTriggerOther'.freeze
      ONE_TRIGGER_ONE_CANCEL_OTHER = 'oneTriggerOneCancelOther'.freeze
      OTOCO = 'oneTriggerOneCancelOther'.freeze
    end

    module NotificationType
      SNAPSHOT = 'snapshot'.freeze
      UPDATE = 'update'.freeze
      DATA = 'data'.freeze
      COMMAND = 'command'.freeze
    end

    module SubscriptionMode
      UPDATES = 'updates'.freeze
      BATCHES = 'batches'.freeze
    end
  end
end
