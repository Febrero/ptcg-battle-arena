module Configs
  class GetHomeConfig < ApplicationService
    def call(wallet_addr)
      {
        highlight: highlight,
        games_of_day: games_of_day,
        drop: drop,
        daily: daily(wallet_addr),
        news: news
      }
    end

    private

    def news
      # TODO: put this in v1 scope, but
      articles, _page, _per_page, _total = ArticlesSearch.new({}).search
      ActiveModel::Serializer::CollectionSerializer.new(
        articles,
        {serializer: V1::ArticleSerializer}
      )
    end

    def highlight
      game_modes = GameMode.where(active: true, admin_only: false, home_highlight: true).to_a

      # filter in memory by state for each type of game mode

      ActiveModel::Serializer::CollectionSerializer.new(
        game_modes,
        {serializer: V1::HomeHighlightSerializer}
      )
    end

    def games_of_day
      today = Date.today
      today_games = GameMode.where(
        :active => true,
        :admin_only => false,
        :start_date.lte => today.end_of_day,
        :end_date.gte => today.beginning_of_day,
        :_type.in => ["Survival", "Playoff"]
      )

      if today_games.empty?
        today_games = Arena.all
      end

      ActiveModel::Serializer::CollectionSerializer.new(
        today_games,
        {serializer: V1::HomeGameModesOfDaySerializer}
      )
    end

    def drop
      drop_page = GetDropPage.call
      {
        web_site_url: "#{Rails.application.config.organya_url}collections/upcoming-drops",
        background_image_url: drop_page["home_background_image_url"],
        foreground_image_url: drop_page["home_foreground_image_url"]
      }
    end

    def daily wallet_addr
      today = Date.today
      quest = GameType::Quest.where(active: true).first
      quest_profile = GameType::QuestProfile.where(wallet_addr: wallet_addr, quest: quest).first

      {
        completed: (quest_profile&.last_game_played&.to_date == today),
        end_date: today.end_of_day,
        background_image_url: quest&.home_background_image_url,
        foreground_image_url: quest&.home_foreground_image_url
      }
    end
  end
end
