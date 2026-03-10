require "rails_helper"

RSpec.describe V1::UserActivities::GamePlayerSerializer, type: :serializer, vcr: true do
  let!(:game) {
    create(:game, :arena, players_wallet_addresses: [
      "0x20b2fc867D736F45D58B9991a52B874F4181c4Ee",
      "0xc1bFa2B8950c00BD0a5a5eC1fb512e15c31ED63b"
    ])
  }
  let!(:game_player) { create(:game_player, game: game, wallet_addr: "0x20b2fc867D736F45D58B9991a52B874F4181c4Ee") }
  let(:profiles) do
    {
      data: [
        {
          id: "61def23714e91300112b01d8",
          type: "profiles",
          attributes: {
            wallet_addr: "0xc1bFa2B8950c00BD0a5a5eC1fb512e15c31ED63b",
            username: "pabloSouza",
            created_at: "2022-01-12T15:22:31.792Z"
          },
          relationships: {
            avatar: {
              data: {
                id: "61dd68dde79ea90e8b4337b7",
                type: "avatars"
              }
            }
          }
        }, {
          id: "61deb68014e91300112b01d2",
          type: "profiles",
          attributes: {
            wallet_addr: "0x20b2fc867D736F45D58B9991a52B874F4181c4Ee",
            username: "PauloPinhoBK",
            created_at: "2022-01-12T11:07:45.354Z"
          },
          relationships: {
            avatar: {
              data: {
                id: "61b8fea1b79471014df8b77c",
                type: "avatars"
              }
            }
          }
        }
      ],
      included: [
        {
          id: "61dd68dde79ea90e8b4337b7",
          type: "avatars",
          attributes: {
            uid: 6,
            url: "https://realfevr-production.s3.eu-central-1.amazonaws.com/nfts-markeplace/Avatar-6.jpg",
            price: 0.0
          }
        },
        {
          id: "61b8fea1b79471014df8b77c",
          type: "avatars",
          attributes: {
            uid: 9999,
            url: "https://realfevr-production.s3.eu-central-1.amazonaws.com/nfts-markeplace/Avatar-default.jpg",
            price: 0.0
          }
        }
      ],
      meta: {
        current_page: 1,
        next_page: 1,
        prev_page: 1,
        total_pages: 1,
        total_count: 2
      }
    }
  end

  subject do
    V1::UserActivities::GamePlayerSerializer.new(game_player, {profiles: profiles.deep_stringify_keys}).serializable_hash
  end

  it "contains info related to game player" do
    expect(subject).to include(:goals_scored, :outcome, :username, :avatar_url, :level)
  end
end
