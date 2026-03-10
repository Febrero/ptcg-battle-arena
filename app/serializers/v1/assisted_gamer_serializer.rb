module V1
  class AssistedGamerSerializer < ActiveModel::Serializer
    attributes :wallet_addr,
      :ai_mode,
      :deck,
      :profile,
      :avatar,
      :week_days_that_play,
      :day_hours_that_play,
      :max_daily_games,
      :todays_total_games_played

    def deck
      return {} if object.valid_deck(instance_options[:deck_stars].to_i).nil?
      DeckCollectionSerializer.new(object.valid_deck(instance_options[:deck_stars].to_i))
    rescue
      {}
    end

    def profile
      # GetProfilesByWalletAddresses.call(filter: {wallet_addr: object.wallet_addr})["data"].first
      _profile.as_json
    rescue
      {}
    end

    def avatar
      _profile.avatar.as_json
    rescue
      {}
    end

    def _profile
      @p ||= NftsApi::Profile.where(wallet_addr: object.wallet_addr).first
    end
  end
end
