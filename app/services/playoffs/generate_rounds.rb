module Playoffs
  class GenerateRounds
    include Callable

    attr_reader :playoff

    def initialize(playoff_uid)
      @playoff = Playoff.find_by(uid: playoff_uid.to_i)
    end

    def call
      playoff.brackets.first.round.times do |r_number|
        playoff.rounds << Playoffs::Round.new(number: (r_number + 1), duration: playoff.default_round_duration)
      end
      playoff.save!
    end
  end
end
