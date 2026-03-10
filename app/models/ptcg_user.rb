# frozen_string_literal: true

class PtcgUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ptcg_user_id, type: String
  field :username, type: String

  index({ ptcg_user_id: 1 }, { unique: true, name: "ptcg_user_id_index" })

  has_one :credit_balance, foreign_key: :ptcg_user_id, primary_key: :ptcg_user_id
end
