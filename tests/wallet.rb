require 'json'

# loads a json with keys
class Wallet
  def initialize
    file = File.open '../../wallet.json'
    keys = JSON.load file # rubocop:disable Security/JSONLoad
    @eth = keys['eth']
  end

  attr_reader :eth
end
