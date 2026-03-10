class SurvivalPlayer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :wallet_addr, type: String
  field :active_entry_id, type: String
  field :survival_id, type: Integer
  field :games_on_survival, type: Array, default: []

  belongs_to :survival, primary_key: :uid

  embeds_many :entries, class_name: "SurvivalPlayers::Entry"

  index({wallet_addr: 1}, {name: "survival_player_wallet_addr_index", background: true})
  index({active_entry_id: 1}, {name: "survival_player_active_entry_id_index", background: true})

  def active_entry
    return nil unless active_entry_id

    entries.find(active_entry_id)
  end

  # TODO validate places where it's called, maybe should be the last_entry (prize generation for example)
  def current_entry
    entry = entries.order(created_at: :desc).first

    raise Survivals::EntryNotFound if entry.blank?

    entry
  end

  def begin_streak(ticket_id)
    raise Survivals::MultipleActiveStreak.new(wallet_addr, survival_id) if active_entry_id.present?

    entry = entries.create(levels_completed: 	 0,
      ticket_id: 		 			 ticket_id,
      ticket_submitted_at: Time.now,
      closed: 						 false,
      closed_at: 					 nil,
      games_ids:           [])

    update(active_entry_id: entry.id.to_s)

    entry
  end

  def update_current_streak_level game_id
    active_entry.inc(levels_completed: 1)
    active_entry.games_ids << game_id.to_s

    games_on_survival << game_id.to_s

    save
  end

  def finish_streak game_id = nil
    active_entry.closed = true
    active_entry.closed_at = Time.now
    last_entry = game_id
    if game_id
      active_entry.games_ids << game_id.to_s
      games_on_survival << game_id.to_s
    else
      last_entry = active_entry.games_ids.last
    end

    # check if last entry is still active because jobs finish streak and when games ends the streak already is finish

    if last_entry # otherwise the player didn't play any game on this streak
      # get last game if streak is finish when he loses
      game = Game.find_by(game_id: last_entry)

      prize_amount, prize_type = Survivals::CalculatePrizeValue.call(game, nil, wallet_addr)

      Survivals::GeneratePrize.call(survival, self, last_entry)

      # we want the active_entry_id in this service (faster than fetching the last one)
      Survivals::SendStreakEventToKafka.call(self, prize_amount, prize_type)

      UserActivity.create(
        wallet_addr: wallet_addr,
        event_info: {entry_id: active_entry_id.to_s},
        source: survival,
        season_uid: Season.currently_active.first.uid,
        event_date: Time.now
      )
    end

    self.active_entry_id = nil

    save
  end
end
