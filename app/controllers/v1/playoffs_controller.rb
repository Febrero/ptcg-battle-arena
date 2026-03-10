module V1
  class PlayoffsController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::PlayoffsControllerDoc

    prepend_before_action :authenticate_user!, only: [:current_bracket]
    before_action :get_playoff, only: [:show, :update, :destroy, :create_team, :current_bracket, :current_bracket_wallet, :prize_config, :reset, :advance, :register, :get_prizes, :brackets, :games_round]
    before_action :auth_frontend, except: [:prize_config]
    before_action :external_api, only: [:prize_config]
    around_action :use_read_only_databases

    api :GET, "/playoffs", "List of playoffs"
    param_group :playoffs_controller_index, Docs::V1::PlayoffsControllerDoc
    def index
      collection, page, per_page, total = PlayoffsSearch.new(search_params).search

      render json: collection,
        each_serializer: PlayoffSerializer,
        with_teams: !!search_params[:teams],
        with_brackets_info: !!search_params[:brackets],
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :GET, "/playoffs/:uid", "Playoff details"
    param_group :playoffs_controller_show, Docs::V1::PlayoffsControllerDoc
    def show
      render json: @playoff,
        serializer: PlayoffSerializer,
        with_teams: !!params[:teams],
        with_brackets_info: !!params[:brackets],
        adapter: :json_api,
        status: :ok
    end

    api :GET, "/playoffs/:uid/prize_config", "Playoff details"
    param_group :playoffs_controller_show_prize_config, Docs::V1::PlayoffsControllerDoc
    def prize_config
      render json: @playoff,
        serializer: PlayoffSerializer,
        with_prize_config: true,
        adapter: :json_api,
        status: :ok
    end

    api :GET, "/playoffs/:uid/reset", "Playoff reset"
    # TODO DELETE
    def reset
      unless Rails.env.production?
        # Code to be executed if the environment is not production
        # Add your logic here
        @playoff.brackets.delete_all
        @playoff.teams.delete_all
        @playoff.rounds.delete_all
        @playoff.state = "upcoming"
        @playoff.winner_team_id = nil
        @playoff.open_date = Time.now.utc + 2.minutes
        @playoff.current_round = 1
        @playoff.save(validate: false)
        Playoffs::CalculatePrizePool.call(@playoff, true)
        Playoffs::Notificator.call(@playoff.uid, Playoffs::Notificator::TYPE_STATE)
        head :ok
      end
    end

    api :GET, "/playoffs/:uid/register", "Playoff register"
    # TODO DELETE
    def register
      unless Rails.env.production?
        wallets_param = params[:wallets]

        # Split the wallets_param by comma to get an array of wallet addresses
        wallets_array = wallets_param.split(",")
        wallets_array.each do |wallet|
          wallet, name = wallet.split("#")
          playoff_team = Playoffs::Team
            .new({
              wallet_addr: wallet,
              wallet_addr_downcased: wallet.downcase,
              name: name,
              ticket_id: @playoff.compatible_ticket_ids[0].to_s,
              playoff: @playoff
            })
          playoff_team.save
          ::Playoffs::CalculatePrizePool.call(@playoff, true)
        end
        head :ok
      end
    end

    api :GET, "/playoffs/:uid/advance", "Playoff advance"
    # TODO DELETE
    def advance
      unless Rails.env.production?
        # Code to be executed if the environment is not production
        # Add your logic here
        if @playoff.state == "upcoming"
          @playoff.open!
          Playoffs::Notificator.call(@playoff.uid, Playoffs::Notificator::TYPE_STATE)
        elsif @playoff.state == "opened"
          @playoff.pregame!
          Playoffs::Notificator.call(@playoff.uid, Playoffs::Notificator::TYPE_STATE)
        elsif @playoff.state == "warmup"
          @playoff.start!
          Playoffs::Notificator.call(@playoff.uid, Playoffs::Notificator::TYPE_STATE)
        elsif @playoff.state == "ongoing"
          Playoffs::AdvanceRound.call(@playoff.uid)
        end
        render json: @playoff.reload, serializer: PlayoffSerializer, adapter: :json_api, status: :ok
      end
    end

    api :GET, "/playoffs/:uid/current_bracket", "Playoff Current Bracket"
    param_group :playoffs_controller_current_bracket, Docs::V1::PlayoffsControllerDoc
    def current_bracket
      current_bracket_response @user_data["publicAddress"]
    end

    api :GET, "/playoffs/:uid/brackets", "Playoff brackets"
    def brackets
      render json: {data: @playoff.flat_brackets}, status: :ok
    end

    api :GET, "/playoffs/:uid/games_round/:round", "Playoff games by round"
    def games_round
      round = params[:round].to_i
      max_rounds = @playoff.total_rounds
      round = max_rounds if round < 1 || round > max_rounds

      render json: {data: @playoff.round_games(round)}, status: :ok
    end

    api :GET, "/playoffs/:uid/current_bracket/:wallet_addr", "Playoff Current Bracket"
    param_group :playoffs_controller_current_bracket, Docs::V1::PlayoffsControllerDoc
    def current_bracket_wallet
      current_bracket_response params[:wallet_addr]
    end

    api :POST, "/playoffs", "Create playoff (Authenticated)"
    # param_group :playoffs_controller_show, Docs::V1::ArenasControllerDoc
    def create
      # Remove ternary operator when Playoff model's token function is both in master and staging
      playoff = Playoff.new(playoff_params)

      playoff.total_prize_pool = 0.0 unless playoff_params[:total_prize_pool]

      if playoff.save
        render json: playoff, serializer: PlayoffSerializer, adapter: :json_api, status: :ok
      else
        # render json: playoff.errors.messages, status: :bad_request
        render json: playoff, adapter: :json_api, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
      end
    end

    api :PUT, "/playoffs/:uid", "Update playoff (Authenticated)"
    # param_group :arenas_controller_update, Docs::V1::ArenasControllerDoc
    def update
      # Remove ternary operator when Playoff model's token function is both in master and staging
      if @playoff.update(playoff_params)
        render json: @playoff, serializer: PlayoffSerializer, adapter: :json_api, status: :ok
      else
        # render json: @playoff.errors.messages, status: :bad_request
        render json: @playoff, adapter: :json_api, status: :unprocessable_entity, serializer: ActiveModel::Serializer::ErrorSerializer
      end
    end

    # we should change this name and also authentication allowed method shoould be only to internal api
    def change_state
      updated_playoff = ChangePlayoffStateViaAdmin.call(params[:uid], params[:state_event])

      render json: updated_playoff, serializer: PlayoffSerializer, adapter: :json_api, status: :ok
    rescue AASM::InvalidTransition => e
      Airbrake.notify("INVALID STATE TRANSACTION", {
        exception_message: e.message,
        playoff_uid: updated_playoff.uid
      })
      render json: updated_playoff, adapter: :json_api, status: :bad_request, serializer: ActiveModel::Serializer::ErrorSerializer
    rescue UnrecognizedPlayoffStateEvent => e
      Airbrake.notify(e)
      render json: updated_playoff, adapter: :json_api, status: :bad_request, serializer: ActiveModel::Serializer::ErrorSerializer
    rescue => e
      Airbrake.notify(e)
      render json: updated_playoff, adapter: :json_api, status: :internal_server_error, serializer: ActiveModel::Serializer::ErrorSerializer
    end

    def destroy
      if @playoff.state == "upcoming"
        @playoff.destroy
      else
        render json: @playoff, adapter: :json_api, status: :bad_request, serializer: ActiveModel::Serializer::ErrorSerializer
      end
    end

    def get_prizes
      render json: {
        data: {
          id: @playoff.id,
          type: @playoff.class,
          attributes: {
            prizes: @playoff.get_prizes
          }
        }
      }, adapter: :json_api, status: :ok
    end

    private

    def current_bracket_response wallet_addr
      if @playoff
        begin
          render json: find_current_bracket(@playoff, wallet_addr),
            serializer: BracketSerializer,
            adapter: :json_api,
            status: :ok
        rescue ::Playoffs::NoCurrentBracket, ::Playoffs::TeamNotInPlayoff => e
          render json: {msg: e.msg, id: e.error_id}, status: :not_found
        rescue => e
          render json: e.msg, status: :bad_request
        end
      else
        head :not_found
      end
    end

    def get_playoff
      @playoff = Playoff.where(uid: params[:uid]).first
      head :not_found if !@playoff
    end

    def params_show
      params.permit(:with_brackets_info, :uid)
    end

    def search_params
      params.permit(:teams, :brackets, :sort, filter: [:state, :active, :admin_only, :admin, :erc20_name, :has_custom_prize, :xp_level], page: [:page, :per_page])
    end

    def playoff_params
      # params.require(:data).require(:attributes).permit(
      #   :name,
      #   :open_date,
      #   :active,
      #   :start_date,
      #   :end_date,
      #   :min_teams,
      #   :max_teams,
      #   :min_deck_tier,
      #   :max_deck_tier,
      #   :card_image_url,
      #   :background_image_url,
      #   layout_colors: []
      # )
      params.require(:data).require(:attributes).permit(
        :name,
        :active,
        :admin_only,
        :open_date,
        :card_image_url,
        :min_teams,
        :max_teams,
        :min_deck_tier,
        :max_deck_tier,
        :partner_config,
        :total_prize_pool,
        :open_timeframe,
        :pregame_timeframe,
        :max_wait_minutes_to_join,
        :spend_ticket,
        :ticket_amount_needed,
        :ticket_factory_contract_address,
        :ticket_locker_and_distribution_contract_address,
        :erc20_name,
        :erc20_name_alt,
        :erc20_image_url_alt,
        :has_custom_prize,
        :entry_price_image_url,
        :erc20_rewards_first_image_url,
        :erc20_rewards_second_image_url,
        :erc20_rewards_third_image_url,
        :erc20_rewards_default_image_url,
        :prize_config_id,
        :prize_config,
        :prize_pool_winner_share,
        :prize_pool_realfevr_share,
        :prize_pool_possible_cashback_share,
        :rf_percentage,
        :burn_percentage,
        :possible_cashback_percentage,
        :total_prize_pool,
        :multiplier_prize,
        :home_highlight,
        :home_highlight_image_url,
        :home_highlight_image_mobile_url,
        :min_xp_level,
        :max_xp_level,
        compatible_ticket_ids: []
      )
    end

    def team_params
      params.require(:data).require(:attributes).permit(
        :wallet_addr
      )
    end

    def find_current_bracket(playoff, wallet_addr)
      team = playoff.teams.where(wallet_addr_downcased: wallet_addr.downcase).first
      raise ::Playoffs::TeamNotInPlayoff.new("Team is not in playoff") if !team

      current = team.current_bracket

      raise ::Playoffs::NoCurrentBracket.new("There are no current bracket") if !current

      current
    end
  end
end
