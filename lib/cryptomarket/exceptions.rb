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
    end
end