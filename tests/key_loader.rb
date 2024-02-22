require 'json'

# loads a json with keys
class KeyLoader
  file = File.open '../../keys.json'
  keys = JSON.load file
  @@api_key = keys['apiKey']
  @@api_secret = keys['apiSecret']

  def self.api_key
    @@api_key
  end

  def self.api_secret
    @@api_secret
  end
end
