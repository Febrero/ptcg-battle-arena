# frozen_string_literal: true

module V1
  class VideosController < ApplicationController
    include BasicAuth
    include PaginationMeta
    include Docs::V1::VideosControllerDoc

    before_action :auth_frontend, only: [:index]
    around_action :use_read_only_databases, only: [:index]

    # video

    # [{
    #   uid: 224,
    #   rarity: "Special",
    #   player_name: "Erivaldo Almeida",
    #   drop: "Drop #6",
    #   drop_slug: "#6",
    #   position: "Defender",
    #   defense: 5,
    #   attack: 0,
    #   stamina: 7,
    #   ball_stopper: true,
    #   super_sub: false,
    #   man_mark: 0,
    #   enforcer: false,
    #   inspire: "",
    #   captain: "",
    #   long_passer: false,
    #   box_to_box: false,
    #   dribbler: false,
    #   power: 17,
    #   enabler: "",
    #   energizer: ""
    # }]

    api :GET, "/videos", "Videos index (Authenticaded)"
    param_group :videos_controller_index, Docs::V1::VideosControllerDoc
    def index
      videos = FetchVideos.call({options: {disable_pagination: true}})["data"]
      response = videos.map { |video| video["attributes"] }

      render json: response, status: :ok
    end
  end
end
