module Playoffs
  class TeamNotInPlayoff < StandardError
    attr_reader :msg, :error_id
    def initialize(msg)
      @msg = msg
      @error_id = 0
    end

    def to_s
      msg
    end
  end
end
