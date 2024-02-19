module Cryptomarket
  class SDKException < ::StandardError
  end

  # Exception representing an error from the server
  class APIException < SDKException
    def initialize(hash)
      @code = hash['code']
      @message = hash['message']
      @description = hash['description']
      super
    end

    attr_reader :code, :message, :description

    def to_s
      "#{self.class.name} (code=#{@code}): #{@message}: #{@description}"
    end
  end
end
