module Survivals
  class PlayerFieldsMissing < StandardError
    def to_s
      "There are missing fields on player creation."
    end
  end
end
