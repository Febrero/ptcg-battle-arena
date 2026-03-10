module Playoffs
  class NoCurrentBracket < StandardError
    attr_reader :msg, :error_id
    def initialize(msg)
      @msg = msg
      @error_id = 1
    end

    def to_s
      msg
    end
  end
end
