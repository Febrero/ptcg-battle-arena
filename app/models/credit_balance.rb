# frozen_string_literal: true

class CreditBalance
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ptcg_user_id, type: String
  field :balance, type: Float, default: 0.0
  field :last_synced_at, type: Time

  index({ ptcg_user_id: 1 }, { unique: true, name: "credit_balance_ptcg_user_id_index" })
end
