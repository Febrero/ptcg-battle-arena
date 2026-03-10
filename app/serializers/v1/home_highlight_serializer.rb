module V1
  class HomeHighlightSerializer < ActiveModel::Serializer
    attributes :uid, :game_mode, :name, :home_highlight_image_url, :home_highlight_image_mobile_url, :prize_pool_winner_share, :entry_price_image_url, :event_data

    def game_mode
      object._type
    end

    def event_data
      case object._type
      when "Survival" then survival_event_data
      when "Playoff" then playoff_event_data
      end
    end

    def survival_event_data
      {
        start_date: object.start_date,
        end_date: object.end_date,
        max_deck_tier: object.max_deck_tier,
        state: object.state,
        levels: object.levels_count

      }
    end

    def playoff_event_data
      {
        start_date: object.start_date,
        open_date: object.open_date,
        end_date: object.timeframes[:end_date],
        max_deck_tier: object.max_deck_tier,
        state: object.state
      }
    end
  end
end
