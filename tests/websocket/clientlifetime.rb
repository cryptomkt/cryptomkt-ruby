require 'test/unit'
require 'lib/websocket/MarketDataClient'
require_relative '../rest/keyloader'
require_relative 'sequenceFlow'
require_relative 'timeFlow'
require_relative '../rest/checks'

class TestWSClientLifetime < Test::Unit::TestCase
    @@SECOND = 1
    @@MINUTE = 60
    @@HOUR = 3600

    def test_public_client_lifetime
        @wsclient = MarketDataClient.new

        @wsclient.onclose = Proc.new {puts "closing";}
        @wsclient.onconnect = Proc.new {puts "connected"}
        @wsclient.onerror = Proc.new {|error| puts "error", error}

        @wsclient.connect
        sleep(5 * @@SECOND)
        @wsclient.close
        sleep(2 * @@SECOND)
    end
end
