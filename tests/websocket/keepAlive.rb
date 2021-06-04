require 'test/unit'
require 'lib/websocket/wsClient'
require_relative '../rest/keyloader'

class TestWStrading < Test::Unit::TestCase
    def setup
        @wsclient = WSClient.new apiKey:Keyloader.apiKey, apiSecret:Keyloader.apiSecret
        sleep(3)
        @wsclient.authenticate
    end

    @@resultCallback = Proc.new {|error, result| 
        if not error.nil?
            puts 'an error arrived'
            puts error
        else
            puts result
        end
    }
    @@feedCallback = Proc.new {|feed| 
        puts "feed: " + Time.now.to_s
    }

    def test_keep_socket_alive
        @wsclient.subscribeTicker @@feedCallback, @@resultCallback
        sleep(3*60*60)
    end
end