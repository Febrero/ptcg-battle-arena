class UnrecognizedPlayoffStateEvent < StandardError
  def initialize(invalid_state_event)
    @invalid_state_event = invalid_state_event
  end

  def to_s
    "The state change event of this playoff is unrecognized - #{@invalid_state_event}"
  end
end
