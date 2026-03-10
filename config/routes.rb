require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  get "ping" => "application#ping"

  Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.config.sidekiqweb_basic_auth[:username])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.config.sidekiqweb_basic_auth[:password]))
  end

  apipie

  mount Sidekiq::Web => "/sidekikas"

  namespace :v1 do
    mount Auth::Engine => "/users"
    mount RealfevrLibs::Engine => "/"

    resources :sample_decks, only: [:show], param: :stars
    resources :videos, only: [:index, :update], param: :nft_uid
    resources :grey_cards, only: [:index]
    resources :wallet_videos, only: [] do
      collection do
        get :wallet_collection
      end
    end
    resources :wallet_grey_cards, only: [:index, :show] do
      collection do
        get :wallet_collection
      end
    end
    resources :arenas
    resources :survivals, param: :uid
    resources :survival_players, only: %i[index create]
    resource :survival_player do
      member do
        get :current_entry
        get "last_entry" => "survival_players#current_entry"
      end
    end

    namespace :playoffs do
      resources :prize_configs, only: [:index]
    end

    resources :playoffs, param: :uid do
      member do
        get "reset", to: "playoffs#reset"
        get "advance", to: "playoffs#advance"
        get "register", to: "playoffs#register"
        get "prize_config", to: "playoffs#prize_config"
        get "brackets", to: "playoffs#brackets"
        get "current_bracket", to: "playoffs#current_bracket"
        get "games_round/:round", to: "playoffs#games_round"
        get "current_bracket/:wallet_addr", to: "playoffs#current_bracket_wallet"
        put :change_state
        get :get_prizes
      end
    end

    resources :playoff_teams, only: %i[index show create]
    resources :tickets do
      collection do
        get "meta/:bc_ticket_id" => "tickets#meta", :param => :bc_ticket_id
        get "by_game_mode" => "tickets#by_game_mode"
      end
    end
    resources :tokens, only: [:index]
    resources :configs, only: [:index] do
      collection do
        get :site
        get :game
        get :home
      end
    end
    resources :white_list, only: [:show], param: :address
    resources :avatars, only: [:index]
    resources :games, only: [:index, :show] do
      collection do
        get "by_game_id/:game_id", to: "games#by_game_id"
        get :info
      end
    end
    resources :profiles, only: %i[show update], param: :wallet_addr do
      collection do
        put :confirm_email
        put :validate
        get :leaderboards_info
        get "ban_info/:wallet", to: "profiles#ban_info"
      end
    end
    resources :decks do
      collection do
        get :list # ! this action should be index after FBA migration
        # TODO REMOVE NEXT LINE
        get "user" => "decks#index"
      end
      # TODO REMOVE NEXT 3 LINES
      member do
        get "user" => "decks#show"
      end
    end
    resources :ticket_balances, only: [] do
      collection do
        get :user
        put :spend
      end
    end
    resources :ticket_bundles
    resources :ticket_offers, expect: [:destroy] do
      collection do
        put :export_csv
      end
    end
    resources :card_offers, expect: [:update, :destroy]
    resources :start_game_locks, only: [] do
      collection do
        post :lock
      end
    end
    resources :rewards, only: [] do
      collection do
        get :wallet_info
        get "wallet_rewards/:game_id", to: "rewards#wallet_rewards"
        get "wallet_rewards_tmp/:game_id", to: "rewards#wallet_rewards_tmp"
      end
    end
    resources :standalone_builds do
      collection do
        get "/:version/control", to: "standalone_builds#control", constraints: {version: /[^\/]+/} # allow dots on url (standalone_builds/1.1.2/control)
      end
    end
    get "/leaderboards/battle_arena/game_modes/:wallet_addr" => "leaderboards#game_modes_profile"
    get "/leaderboards/:source(/:time_range)(/:season_survival_arena_playoff)" => "leaderboards#show"

    resources :splash_screens
    resources :tutorial_progresses, only: [:index, :show] do
      collection do
        post :new_step
        delete :reset
        delete :reset_all
      end
    end

    resources :quests, only: [:index] do
      collection do
        get "/:uid/configs", to: "quests#configs"
        get "/:uid/current/:wallet_addr", to: "quests#current_streak"
      end
    end
    resources :quest_streaks, only: [:index]
    resources :seasons

    get "/game_mode/:uid/info" => "game_mode#game_mode_config"

    namespace :player_profile do
      resources :user_activities, only: [:show] do
        collection do
          get :user
        end
      end

      resource :stats, only: [] do
        get :games
        get :decks
        get :moments
        get :game_metrics
        get :tournaments
      end
    end

    resources :assisted_gamers do
      collection do
        get :search
        post :upload_csv
      end
    end

    resources :game_mode_partner_configs, param: :uid

    resources :articles, param: :uid do
      collection do
        get :active
      end
    end

    get "/top_moments" => "top_moments#show"

    get "/profile" => "profiles#show"

    resources :exports, only: [] do
      collection do
        get :active
        post :playoffs_activity
        post :survivals_activity
      end
    end
  end

  scope module: :v1 do
    mount Auth::Engine => "/users"
    mount RealfevrLibs::Engine => "/"

    resources :sample_decks, only: [:show], param: :stars
    resources :videos, only: [:index, :update], param: :nft_uid
    resources :grey_cards, only: [:index]
    resources :wallet_videos, only: [] do
      collection do
        get :wallet_collection
      end
    end
    resources :wallet_grey_cards, only: [:index, :show] do
      collection do
        get :wallet_collection
      end
    end
    resources :arenas
    resources :survivals, param: :uid
    resources :survival_players, only: %i[index create]
    resource :survival_player do
      member do
        get :current_entry
        get "last_entry" => "survival_players#current_entry"
      end
    end

    namespace :playoffs do
      resources :prize_configs, only: [:index]
    end

    resources :playoffs, param: :uid do
      member do
        get "reset", to: "playoffs#reset"
        get "advance", to: "playoffs#advance"
        get "register", to: "playoffs#register"
        get "prize_config", to: "playoffs#prize_config"
        get "brackets", to: "playoffs#brackets"
        get "current_bracket", to: "playoffs#current_bracket"
        get "games_round/:round", to: "playoffs#games_round"
        get "current_bracket/:wallet_addr", to: "playoffs#current_bracket_wallet"
        put :change_state
        get :get_prizes
      end
    end

    resources :playoff_teams, only: %i[index show create]
    resources :tickets do
      collection do
        get "meta/:bc_ticket_id" => "tickets#meta", :param => :bc_ticket_id
        get "by_game_mode" => "tickets#by_game_mode"
      end
    end
    resources :tokens, only: [:index]
    resources :configs, only: [:index] do
      collection do
        get :site
        get :game
        get :home
      end
    end
    resources :white_list, only: [:show], param: :address
    resources :avatars, only: [:index]
    resources :games, only: [:index, :show] do
      collection do
        get "by_game_id/:game_id", to: "games#by_game_id"
        get :info
      end
    end
    resources :profiles, only: %i[show update], param: :wallet_addr do
      collection do
        put :confirm_email
        put :validate
        get :leaderboards_info
        get "ban_info/:wallet", to: "profiles#ban_info"
      end
    end
    resources :decks do
      collection do
        get :list # ! this action should be index after FBA migration
        # TODO REMOVE NEXT LINE
        get "user" => "decks#index"
      end
      # TODO REMOVE NEXT 3 LINES
      member do
        get "user" => "decks#show"
      end
    end
    resources :ticket_balances, only: [] do
      collection do
        get :user
        put :spend
      end
    end
    resources :ticket_bundles
    resources :ticket_offers, expect: [:destroy] do
      collection do
        put :export_csv
      end
    end
    resources :card_offers, expect: [:update, :destroy]
    resources :start_game_locks, only: [] do
      collection do
        post :lock
      end
    end
    resources :rewards, only: [] do
      collection do
        get :wallet_info
        get "wallet_rewards/:game_id", to: "rewards#wallet_rewards"
        get "wallet_rewards_tmp/:game_id", to: "rewards#wallet_rewards_tmp"
      end
    end
    resources :standalone_builds do
      collection do
        get "/:version/control", to: "standalone_builds#control", constraints: {version: /[^\/]+/} # allow dots on url (standalone_builds/1.1.2/control)
      end
    end
    get "/leaderboards/battle_arena/game_modes/:wallet_addr" => "leaderboards#game_modes_profile"
    get "/leaderboards/:source(/:time_range)(/:season_survival_arena_playoff)" => "leaderboards#show"

    resources :splash_screens
    resources :tutorial_progresses, only: [:index, :show] do
      collection do
        post :new_step
        delete :reset
        delete :reset_all
      end
    end

    resources :quests, only: [:index] do
      collection do
        get "/:uid/configs", to: "quests#configs"
        get "/:uid/current/:wallet_addr", to: "quests#current_streak"
      end
    end
    resources :quest_streaks, only: [:index]
    resources :seasons

    get "/game_mode/:uid/info" => "game_mode#game_mode_config"

    namespace :player_profile do
      resources :user_activities, only: [:show] do
        collection do
          get :user
        end
      end

      resource :stats, only: [] do
        get :games
        get :decks
        get :moments
        get :game_metrics
        get :tournaments
      end
    end

    resources :assisted_gamers do
      collection do
        get :search
        post :upload_csv
      end
    end

    resources :game_mode_partner_configs, param: :uid

    get "/top_moments" => "top_moments#show"

    get "/profile" => "profiles#show"

    resources :exports, only: [] do
      collection do
        post :playoffs_activity
        post :survivals_activity
      end
    end

    resources :articles, param: :uid do
      collection do
        get :active
      end
    end

  end
end
