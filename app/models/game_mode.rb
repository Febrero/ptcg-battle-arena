class GameMode
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :uid, type: Integer
  field :name, type: String

  field :total_prize_pool, type: Float

  field :prize_pool_winner_share, type: Float
  field :prize_pool_realfevr_share, type: Float
  field :prize_pool_possible_cashback_share, type: Float

  field :compatible_ticket_ids, type: Array
  field :erc20_name, type: String
  field :active, type: Boolean
  field :layout_colors, type: Array
  field :card_image_url, type: String
  field :background_image_url, type: String
  field :ticket_factory_contract_address, type: String
  field :ticket_locker_and_distribution_contract_address, type: String
  field :ticket_id_to_offer, type: String
  field :rf_percentage, type: Float, default: 4.0 # 4.0%
  field :burn_percentage, type: Float, default: 1.0 # 1.0 %
  field :possible_cashback_percentage, type: Float, default: 5.0 # 5.0 %
  field :entry_price_image_url, type: String
  field :rewards_multiplier, type: Integer
  field :ticket_amount_needed, type: Integer, default: 1
  field :state, type: String
  field :erc20_image_url_alt, type: String # if we want set an difference image prize from default that will be taken from
  field :erc20_name_alt, type: String # if we want set an difference name prize from default that will be taken from
  field :admin_only, type: Boolean, default: false
  field :admin, type: Boolean, default: false
  field :home_highlight, type: Boolean, default: false
  field :home_highlight_image_url, type: String
  field :home_highlight_image_mobile_url, type: String

  field :min_xp_level, type: Integer
  field :max_xp_level, type: Integer

  belongs_to :partner_config, primary_key: :uid, class_name: "GameModePartnerConfig", optional: true

  validates :name, :total_prize_pool, :rf_percentage, :burn_percentage, :possible_cashback_percentage,
    :compatible_ticket_ids, :active, presence: true

  validate :validate_xp_level

  index({uid: 1}, {name: "uid_index", background: true})
  index({compatible_ticket_ids: 1}, {name: "compatible_ticket_ids_index", background: true})
  index({state: 1}, {name: "state_index", background: true, sparse: true})
  index({partner_config_id: 1}, {name: "partner_config_id_index", background: true, sparse: true})

  index({min_xp_level: 1}, {name: "min_xp_level_index", background: true, sparse: true})
  index({max_xp_level: 1}, {name: "max_xp_level_index", background: true, sparse: true})

  def validate_xp_level
    if max_xp_level.to_i < min_xp_level.to_i
      errors.add(:max_xp_level, "The max xp level of game mode can not be lower than min xp level (#{min_xp_level} - #{max_xp_level})")
    end
  end

  def token
    Rails.cache.fetch("GameMode::FetchToken::#{erc20_name}", expires_in: 5.minutes) do
      FetchToken.call(erc20_name)["data"]["attributes"]
    rescue
      {}
    end
  end
  # default_scope -> { where(active: true, admin: false) }

  def available_tickets
    Ticket.where(ticket_factory_contract_address: ticket_factory_contract_address).in(bc_ticket_id: compatible_ticket_ids).to_a
  end

  def winner_percentage
    (100.0 - (rf_percentage + burn_percentage + possible_cashback_percentage)).round(4)
  end

  def winner_share
    @winner_share ||= (winner_percentage / 100.0).round(4)
  end

  def rf_share
    (rf_percentage / 100.0).round(4)
  end

  def burn_share
    (burn_percentage / 100.0).round(4)
  end

  def possible_cashback_share
    (possible_cashback_percentage / 100.0).round(4)
  end

  def calc_prize_pool_winner_share
    (total_prize_pool * winner_share).round(4)
  end

  def calc_prize_pool_realfevr_share
    (total_prize_pool * rf_share).round(4)
  end

  def calc_prize_pool_possible_cashback_share
    (total_prize_pool * possible_cashback_share).round(4)
  end

  def self.ticket_from_uid(uid)
    game_mode = where(uid: uid).first
    Ticket.where(bc_ticket_id: game_mode.ticket_id_to_offer, ticket_factory_contract_address: game_mode.ticket_factory_contract_address).first
  end
end
