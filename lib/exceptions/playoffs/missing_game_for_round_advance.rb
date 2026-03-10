module Playoffs
  class MissingGameForRoundAdvance < StandardError
    def initialize(playoff)
      @playoff = playoff
    end

    def to_s
      "Advance round failed for playoff ##{@playoff.uid} because there were games that didn't finished"
    end
  end
end
