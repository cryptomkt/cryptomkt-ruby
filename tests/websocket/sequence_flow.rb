class SequenceFlow
  def initialize
    @last_sequence = nil
  end

  def checkNextSequence(current_sequence)
    good_flow = true
    good_flow = false if !@last_sequence.nil? && (current_sequence - @last_sequence != 1)
    @last_sequence = current_sequence
    good_flow
  end
end
