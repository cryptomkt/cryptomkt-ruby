# frozen_string_literal: true

module Cryptomarket
  class SDKException < ::StandardError
  end

  # Exception representing an error from the server
  class APIException < SDKException
    def initialize(hash)
      @code = hash['code']
      raw_message = hash['message']
      @description = hash.key?('description') ? hash['description'] : ''
      @message = "#{self.class.name} (code=#{@code}): #{raw_message}. #{@description}"
      super
    end

    attr_reader :code, :message, :description

    def to_s
      @message
    end
  end
end
