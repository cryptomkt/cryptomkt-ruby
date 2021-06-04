require 'json'
require 'faye/websocket'
require 'eventmachine'

require_relative '../exceptions'

module Cryptomarket
    module Websocket
        class WSManager    
            def initialize(handler, url:)
                @url = url
                @handler = handler
                @connected = false
            end

            def connected?
                return @connected
            end

            def connect()
                @thread = Thread.new do
                    EM.run {
                        @ws = Faye::WebSocket::Client.new(@url)
                    
                        @ws.onopen = lambda do |event|
                            @connected = true
                            @handler.on_open()
                        end
                    
                        @ws.onclose = lambda do |close|
                            @handler.onclose()
                            EM.stop
                        end
                        
                        @ws.onerror = lambda do |error|
                            @handler.onerror(error)
                        end
                        
                        @ws.onmessage = lambda do |message|
                            @handler.handle(JSON.parse(message.data.to_s))
                        end     
                    }
                end
            end

            def close 
                @ws.close
                @connected = false
            end

            def send hash
                if not @connected
                    raise Cryptomarket::SDKException.new, "connection closed"
                end
                @ws.send hash.to_json
            end
        end
    end
end