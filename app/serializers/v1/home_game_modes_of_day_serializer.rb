module V1
  class HomeGameModesOfDaySerializer < ActiveModel::Serializer
    attributes :uid, :game_mode, :name, :prize_pool_winner_share, :ticket_amount_needed, :entry_price_image_url, :event_data

    def game_mode
      object._type
    end

    def event_data
      case object._type
      when "Survival" then survival_event_data
      when "Playoff" then playoff_event_data
      when "Arena" then arena_event_data
      end
    end

    def arena_event_data
      {
        start_date: Time.now.beginning_of_day,
        end_date: Time.now.end_of_day,
        erc20_image_url: object.token["image_url"],
        erc20_name: object.erc20_name,
        max_deck_tier: 5,
        state: "active"
      }
    end

    def survival_event_data
      {
        start_date: object.start_date,
        end_date: object.end_date,
        erc20_image_url: object.token["image_url"],
        erc20_name: object.erc20_name,
        max_deck_tier: object.max_deck_tier,
        state: object.state
      }
    end

    def playoff_event_data
      {
        open_date: object.open_date,
        start_date: object.start_date,
        end_date: object.end_date,
        erc20_image_url: object.erc20_image_url_alt.present? ? object.erc20_image_url_alt : object.token["image_url"],
        erc20_name: object.erc20_name_alt.present? ? object.erc20_name_alt : object.erc20_name,
        max_deck_tier: object.max_deck_tier,
        state: object.state
      }
    end
  end
end
