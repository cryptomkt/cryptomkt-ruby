module Cryptomarket
  module Websocket
      class ReusableCallback 
          def initialize(callback, call_count) 
              @call_count =  call_count
              @callback = callback
          end

          def get_callback()
            if  @call_count < 1
              return [nil, false]
            end
            @call_count -= 1
            done_using = @call_count < 1
            return [@callback, done_using]
          end
      end
  end
end