module Survivals
  class EntryNotFound < StandardError
    def to_s
      "There are no entry for this wallet_addr and survival."
    end
  end
end
