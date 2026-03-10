module V1
  class RewardsController < ApplicationController
    include BasicAuth
    include Docs::V1::RewardsControllerDoc

    prepend_before_action :authenticate_user!, except: :wallet_rewards_tmp
    before_action :auth_frontend, except: [:wallet_rewards_tmp]
    before_action :auth_external_api, only: [:wallet_rewards_tmp]

    api :GET, "/rewards/wallet_info", "Wallet rewards info"
    param_group :rewards_controller_wallet, Docs::V1::RewardsControllerDoc
    def wallet_info
      render json: Rewards::FetchWallet.call(@user_data["publicAddress"]), status: 200
    rescue Rewards::ServiceConnectionForbidden
      head :forbidden
    rescue Rewards::ServiceConnectionTimeout
      render json: "Server Timeout", status: :request_timeout
    rescue => e
      Airbrake.notify(e)
      render json: "Internal Server Error", status: :internal_server_error
    end

    api :GET, "/rewards/wallet_rewards", "Wallet rewards for a given game"
    def wallet_rewards
      if get_redis.exists("#{params[:game_id]}::processing") == 1
        render status: :service_unavailable, plain: "The endpoint is not ready. Please try again later.", retry_after: 5.seconds
        return
      end

      wallet_rewards = Rewards::FetchWalletRewards.call(@user_data["publicAddress"], params[:game_id])

      serialized_rewards = []
      wallet_rewards.each_pair do |reward_type, rewards|
        serializer = case reward_type
        when "default_reward" then WalletRewardSerializer
        when "prized_reward" then WalletRewardPrizesSerializer
        end
        rewards.inject(serialized_rewards) do |array, reward|
          array << serializer.new(reward).to_h if serializer.present?
        end
      end

      render json: serialized_rewards, status: :ok
    rescue Rewards::ServiceConnectionForbidden
      head :forbidden
    rescue Rewards::ServiceConnectionTimeout
      render json: "Server Timeout", status: :request_timeout
    rescue => e
      Airbrake.notify(e)
      render json: "Internal Server Error", status: :internal_server_error
    end

    # ! THIS IS A TEMPORARY ENDPOINT USED TO DEBUG REWARDS
    api :GET, "/rewards/wallet_rewards_tmp", "Wallet rewards for a given game"
    def wallet_rewards_tmp
      wallet_rewards = Rewards::FetchWalletRewards.call(params[:wallet_addr], params[:game_id])

      serialized_rewards = []
      wallet_rewards.each_pair do |reward_type, rewards|
        serializer = case reward_type
        when "default_reward" then WalletRewardSerializer
        when "prized_reward" then WalletRewardPrizesSerializer
        end
        rewards.inject(serialized_rewards) do |array, reward|
          array << serializer.new(reward).to_h if serializer.present?
        end
      end

      render json: serialized_rewards, status: :ok
    rescue Rewards::ServiceConnectionForbidden
      head :forbidden
    rescue Rewards::ServiceConnectionTimeout
      render json: "Server Timeout", status: :request_timeout
    rescue => e
      Airbrake.notify(e)
      render json: "Internal Server Error", status: :internal_server_error
    end
  end
end
