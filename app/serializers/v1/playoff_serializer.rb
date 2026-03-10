module V1
  class PlayoffSerializer < GameModeSerializer
    attributes :min_teams,
      :max_teams,
      :timeframes,
      :open_date,
      :open_timeframe,
      :pregame_timeframe,
      :max_wait_minutes_to_join,
      :state,
      :current_round,
      :winner_team_id,
      :winner_team_name,
      :min_deck_tier,
      :max_deck_tier,
      :prize_distribution,
      :rewards_images,
      :erc20_rewards_first_image_url,
      :erc20_rewards_second_image_url,
      :erc20_rewards_third_image_url,
      :erc20_rewards_default_image_url,
      :spend_ticket,
      :has_custom_prize,
      :multiplier_prize,
      :prize_config

    def initialize(object, options = {})
      super(object, options)
      @with_teams = options[:with_teams]
      @with_prize_config = options[:with_prize_config]
      @with_brackets_info = options[:with_brackets_info]
      @videos = {}
    end

    # Once we want to use attributes key for array on response we need to override it
    def attributes(*args)
      hash = super
      if @with_prize_config
        hash[:prize_percentage_per_round] = object.prize_config_per_round_percentage
      end
      if @with_brackets_info
        hash[:brackets_info] = brackets_info
      end

      if @with_teams
        hash[:teams] = teams
      end

      hash
    end

    def prize_config
      PrizeConfigsSerializer.new(object.prize_config).serializable_hash if object.prize_config
    end

    def get_teams
      @teams ||= {}
      @teams[object.uid] ||= object.teams.index_by { |team| team.id.to_s }
    end

    def winner_team_name
      get_teams[object.winner_team_id]&.name if object.winner_team_id
    end

    def timeframes
      object.timeframes
    end

    def brackets_info
      return {} if object.brackets.blank?

      object.format_brackets get_teams
    end

    def prize_distribution
      object.prize_distribution
    end

    def max_teams
      object.max_teams || Playoff::TOTAL_TEAMS_FORMAT.max
    end

    def registration_starts
      object.open_date
    end

    def registration_ends
      object.open_date + object.open_timeframe.minutes
    end

    def rewards_images
      {
        erc20_rewards_first_image_url: object.erc20_rewards_first_image_url,
        erc20_rewards_second_image_url: object.erc20_rewards_second_image_url,
        erc20_rewards_third_image_url: object.erc20_rewards_third_image_url,
        erc20_rewards_default_image_url: object.erc20_rewards_default_image_url
      }
    end

    def teams
      ActiveModel::Serializer::CollectionSerializer.new(
        get_teams.values,
        {serializer: PlayoffTeamSerializer}
      )
    end
  end
end
