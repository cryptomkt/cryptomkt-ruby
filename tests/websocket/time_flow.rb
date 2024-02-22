# frozen_string_literal: true

require 'time'

class TimeFlow
  def initialize
    @last_time = nil
  end

  def check_next_time(timestamp)
    current_time = Time.parse(timestamp)
    good_flow = true
    if !@last_time.nil? && (current_time - @last_time <= 0)
      puts "last:#{@last_time}\tcurrent:#{current_time}"
      good_flow = false
    end
    @last_time = current_time
    good_flow
  end
end
