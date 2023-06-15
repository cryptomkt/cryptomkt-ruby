class SequenceFlow

    def initialize()
        @last_sequence = nil
    end

    def checkNextSequence(current_sequence)
        good_flow = true
        if not @last_sequence.nil? and current_sequence - @last_sequence != 1
            good_flow = false
        end
        @last_sequence = current_sequence
        return good_flow
    end
end