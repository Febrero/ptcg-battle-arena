module Survivals
  class TicketNotSpent < StandardError
    def to_s
      "Deposited tickets missing"
    end
  end
end
