class SequenceFlow

    def initialize()
        @lastSequence = nil
    end

    def checkNextSequence(currentSequence)
        goodFlow = true
        if not @lastSequence.nil? and currentSequence - @lastSequence != 1
            goodFlow = false
        end
        @lastSequence = currentSequence
        return goodFlow
    end
end