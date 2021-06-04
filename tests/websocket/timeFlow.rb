require "time"

class TimeFlow

    def initialize()
        @lastTime = nil
    end

    def checkNextTime(timestamp)
        currentTime = Time.parse(timestamp)
        goodFlow = true
        if not @lastTime.nil? and currentTime - @lastTime <= 0
            puts "last:#{@lastTime}\tcurrent:#{currentTime}"
            goodFlow = false
        end
        @lastTime = currentTime
        return goodFlow
    end
end