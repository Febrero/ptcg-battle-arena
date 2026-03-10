module NftsApi
  class Profile < Base
    self.primary_key = :wallet_addr
  end
end

class NftsApi::Profile::Avatar < NftsApi::Base
  self.primary_key = :id
end
