require "time"

class TimeFlow

    def initialize()
        @last_time = nil
    end

    def checkNextTime(timestamp)
        current_time = Time.parse(timestamp)
        good_flow = true
        if not @last_time.nil? and current_time - @last_time <= 0
            puts "last:#{@last_time}\tcurrent:#{current_time}"
            good_flow = false
        end
        @last_time = current_time
        return good_flow
    end
end