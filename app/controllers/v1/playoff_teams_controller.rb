module V1
  class PlayoffTeamsController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::PlayoffTeamsControllerDoc

    prepend_before_action :authenticate_user!, only: [:create]
    before_action :auth_frontend
    around_action :use_read_only_databases, except: [:create]

    api :GET, "/playoff_teams", "LIST ALL TEAMS (Authenticaded)"
    param_group :playoff_teams_controller_index, Docs::V1::PlayoffTeamsControllerDoc
    def index
      collection, page, per_page, total = PlayoffsTeamSearch.new(playoff_team_list_params).search

      render json: collection,
        each_serializer: PlayoffTeamSerializer,
        adapter: :json_api,
        meta: pagination_dict(page, per_page, total),
        status: :ok
    end

    api :POST, "/playoff_teams", "Register team on playoff (Authenticated)"
    param_group :playoff_teams_controller_create, Docs::V1::PlayoffTeamsControllerDoc
    def create
      # fetch profile data
      # @note TODO why ticket_id
      playoff = Playoff.where(uid: playoff_team_create_params["playoff_id"]).first

      if !playoff
        return render json: {errors: ["Playoff not exist"]}, status: :bad_request
      end

      profile_response, _ = Profile::Fetch.call(@user_data["publicAddress"].dup, request.headers["Authorization"], true)

      profile_xp_level = profile_response["data"]["attributes"]["xp_level"]
      if playoff.min_xp_level.present? && !(playoff.min_xp_level..playoff.max_xp_level).cover?(profile_xp_level)
        return render json: {errors: ["You cant register in this playoff out of xp_level allowed"]}, status: :bad_request
      end

      if playoff.allow_only_wallets_in_whitelist && !::Playoffs::WhiteList.call(playoff.uid, @user_data["publicAddress"])
        return render json: {errors: ["The wallet is not in allow list"]}, status: :bad_request
      end

      # ticket_amount = playoff_team_create_params["ticket_amount"] || playoff.ticket_amount_needed || 1
      ticket_amount = playoff.ticket_amount_needed || 1

      spend_ticket_instance = Tickets::SpendTicketsPlayoff.new(playoff.uid, playoff_team_create_params["ticket_id"].to_i, @user_data["publicAddress"], true, ticket_amount)

      # This operation should be transactional! the user can participate in multiple playoffs at same time and we should keep integrity of ticket balance
      if playoff.should_spend_ticket? && !spend_ticket_instance.charge
        render json: Tickets::SpendTicketsPlayoff.response_error_message(playoff.compatible_ticket_ids), status: 402
        return
      end

      avatar = begin
        profile_response["included"][0]["attributes"]["url"]
      rescue
        nil
      end

      playoff_team = ::Playoffs::Team
        .new({
          wallet_addr: @user_data["publicAddress"],
          wallet_addr_downcased: @user_data["publicAddress"].downcase,
          profile_id: profile_response["data"]["id"],
          xp_level: profile_xp_level,
          name: profile_response["data"]["attributes"]["username"],
          avatar: avatar,
          ticket_amount: ticket_amount,
          ticket_id: playoff_team_create_params["ticket_id"].to_s,
          playoff: playoff
        })

      if playoff_team.save
        ::Playoffs::CalculatePrizePoolJob.perform_async(playoff.uid)
        render json: playoff_team, serializer: PlayoffTeamSerializer, adapter: :json_api, status: :ok
      else
        spend_ticket_instance.revert_charge_entry
        render json: playoff_team.errors.messages, status: :bad_request
      end
    end

    api :GET, "/playoff_teams/:id", "show Playoff Team details"
    param_group :playoff_teams_controller_show, Docs::V1::PlayoffTeamsControllerDoc
    def show
      if (playoff_team = ::Playoffs::Team.where(id: params[:id]).first)
        render json: playoff_team, serializer: PlayoffTeamSerializer, adapter: :json_api, status: :ok
      else
        head :not_found
      end
    end

    private

    def playoff_team_create_params
      params.require(:data).require(:attributes).permit(:playoff_id, :ticket_id, :ticket_amount)
    end

    def playoff_team_list_params
      params.permit(:sort, filter: [:playoff_id, :wallet_addr, :still_in_playoff], page: {})
    end
  end
end
