module Cryptomarket
    class SDKException < ::StandardError
    end

    class APIException < SDKException
        def initialize(hash)
            @code = hash['code']
            @message = hash['message']
            @description = hash['description']
        end

        def code
            return @code
        end

        def message
            return @message
        end

        def description
            return @description
        end

        def to_s
            return "#{self.class().name} (code=#{@code}): #{@message}: #{@description}"
        end
    end
end