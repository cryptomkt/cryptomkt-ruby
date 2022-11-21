require 'json'

class Keyloader
    file = File.open "/home/ismael/cryptomarket/keys-v3.json"
    keys = JSON.load file
    @@apiKey = keys['apiKey']
    @@apiSecret = keys['apiSecret']

    def self.apiKey
        return @@apiKey
    end

    def self.apiSecret
        return @@apiSecret
    end
end