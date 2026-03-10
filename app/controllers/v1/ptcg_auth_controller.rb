# frozen_string_literal: true

module V1
  class PtcgAuthController < ApplicationController
    # POST /v1/auth/ptcg_code
    # Body: { code: "123456" }
    # Returns: { token: "jwt...", user: { id, username, credit_balance } }
    def create
      code = params[:code]
      return render json: { error: "Missing code" }, status: :bad_request unless code.present?

      begin
        ptcg_data = PtcgWorld::ValidateCode.call(code)
      rescue => e
        return render json: { error: e.message }, status: :unauthorized
      end

      ptcg_user_id = ptcg_data["user_id"].to_s
      username     = ptcg_data["username"] || "Trainer#{ptcg_user_id}"
      card_ids     = ptcg_data["cards"] || []
      credit_bal   = ptcg_data["credit_balance"].to_f

      # Find or create user
      user = PtcgUser.find_or_initialize_by(ptcg_user_id: ptcg_user_id)
      user.username = username
      user.save!

      # Sync credit balance
      CreditBalance.find_or_initialize_by(ptcg_user_id: ptcg_user_id).tap do |cb|
        cb.balance = credit_bal
        cb.last_synced_at = Time.current
        cb.save!
      end

      # Sync card collection — map ptcg card IDs to grey cards
      SyncUserCardsJob.perform_async(ptcg_user_id, card_ids)

      # Issue JWT
      payload = {
        ptcg_user_id: ptcg_user_id,
        username: username,
        exp: 24.hours.from_now.to_i
      }
      token = JWT.encode(payload, Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"], "HS256")

      render json: {
        token: token,
        user: {
          id: ptcg_user_id,
          username: username,
          credit_balance: credit_bal
        }
      }, status: :ok
    end
  end
end
