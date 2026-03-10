module Rewards
  class FetchWallet < ApplicationService
    def call(wallet_addr)
      Rewards::Wallet.find(wallet_addr).first
    rescue JsonApiClient::Errors::NotFound
      raise Rewards::WalletNotFound
    rescue JsonApiClient::Errors::RequestTimeout
      raise Rewards::ServiceConnectionTimeout
    rescue JsonApiClient::Errors::AccessDenied
      raise Rewards::ServiceConnectionForbidden
    end
  end
end
