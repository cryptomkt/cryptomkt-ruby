require "securerandom"
require_relative "wsClientBase"

module Cryptomarket
    module Websocket
        class AuthClient < ClientBase
            # Creates a new client
            def initialize(url:, apiKey:, apiSecret:)
                @apiKey = apiKey
                @apiSecret = apiSecret
                super url:url
                @authed = false
            end

            def connected?
                return (super.connected? and @authed)
            end

            # connects via websocket to the exchange and authenticates it.
            def connect
                super
                authenticate(Proc.new {|err, result|
                    if not err.nil?
                        raise err
                    end
                    @authed = true
                })
                while not @authed
                    sleep(1)
                end
            end

            # Authenticates the websocket
            # 
            # https://api.exchange.cryptomkt.com/#socket-session-authentication
            # 
            # +Proc+ +callback+:: Optional. A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}

            def authenticate(callback=nil)
                nonce = SecureRandom.hex
                digest = OpenSSL::Digest.new 'sha256'
                signature = OpenSSL::HMAC.hexdigest digest, @apiSecret, nonce
                params = {
                    'algo'=> 'HS256',
                    'pKey'=> @apiKey,
                    'nonce'=> nonce,
                    'signature'=> signature
                }
                return sendById('login', callback, params)
            end
        end
    end
end