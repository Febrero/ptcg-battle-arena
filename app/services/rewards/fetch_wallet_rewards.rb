module Rewards
  class FetchWalletRewards < ApplicationService
    attr_accessor :rewards

    def call(wallet_addr, game_id)
      @rewards = {"default_reward" => [], "prized_reward" => []}

      get_rewards(wallet_addr, game_id)

      get_ticket_prizes(wallet_addr, game_id)

      @rewards
    end

    private

    def get_rewards(wallet_addr, game_id)
      Rewards::Reward.where(wallet_addr: wallet_addr, game_id: game_id).all.each_with_object(@rewards) do |reward, hash|
        hash["default_reward"] ||= []
        hash["default_reward"] << reward.attributes
      end
    rescue JsonApiClient::Errors::NotFound
      raise Rewards::WalletNotFound
    rescue JsonApiClient::Errors::RequestTimeout
      raise Rewards::ServiceConnectionTimeout
    rescue JsonApiClient::Errors::AccessDenied
      raise Rewards::ServiceConnectionForbidden
    end

    def get_ticket_prizes(wallet_addr, game_id)
      query_params = {
        filter: {
          game_id: game_id,
          wallet_addr: wallet_addr
        }
      }

      rewards_fevr = InternalApi
        .new
        .get("prizes",
          {
            request_uri: "/prizes",
            query: query_params
          }).json

      rewards_fevr["data"].select { |r| r["attributes"]["prize_awarded"] == true }.each do |ticket|
        @rewards["prized_reward"] ||= []
        @rewards["prized_reward"] << ticket["attributes"]
      end
    end
  end
end
