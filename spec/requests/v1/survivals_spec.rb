require "rails_helper"

RSpec.describe "V1::Survivals", type: :request, vcr: true do
  let!(:headers) do
    {"X-RealFevr-Token" => Digest::SHA256.hexdigest(Time.now.utc.to_date.to_s), "X-RealFevr-I-Token" => Rails.application.config.internal_api_key}
  end

  let!(:survivals) do
    create_list(:survival, 3).each_with_index do |survival, i|
      survival.state = (i.odd? ? "open" : "closed")
    end
  end

  describe "Not authorized survival requests" do
    it "index returns not authorized" do
      get "/v1/survivals", headers: {}
      expect(response).to have_http_status(:forbidden)
    end

    it "show returns not authorized" do
      get "/v1/survivals/#{survivals.first.uid}", headers: {}
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET index" do
    context "without filters" do
      before { get "/v1/survivals", headers: headers }

      it "returns http success" do
        expect(response).to have_http_status(:ok)
      end

      it "returns a survivals list" do
        expect(json["data"].size).to eq(3)
      end
    end

    context "with filters" do
      it "filter by state" do
        survivals.first(2).each { |s| s.update_attributes(state: "closed") }

        get "/v1/survivals?filter[state]=closed", headers: headers

        expect(json["data"].size).to eq(2)
      end
    end
  end

  describe "GET show" do
    it "returns http status ok" do
      get "/v1/survivals/#{survivals.first.uid}", headers: headers

      expect(response).to have_http_status(:ok)
    end

    it "returns http not found" do
      get "/v1/survivals/10101010010101", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST show" do
    context "authenticated" do
      it "returns http status ok" do
        post "/v1/survivals", headers: headers, params: {
          data: {
            attributes: {
              name: "Survival1",
              total_prize_pool: "1000",
              prize_pool_winner_share: "100",
              prize_pool_realfevr_share: "900",
              active: true,
              erc20_name: "FEVR",
              ticket_factory_contract_address: "0x456",
              ticket_locker_and_distribution_contract_address: "0x789",
              state: "incoming",
              start_date: Time.now,
              end_date: Time.now,
              min_deck_tier: 1,
              max_deck_tier: 2,
              levels_count: 1,
              background_image_url: "http://google.com",
              layout_colors: ["#000000"],
              compatible_ticket_ids: [1, 2],
              stages: [{
                level: 1, prize_amount: 10, prize_type: "FEVR"
              }]
            }
          }
        }

        expect(response).to have_http_status(:success)
      end
    end

    context "not authenticated" do
      it "returns http status forbidden" do
        post "/v1/survivals", params: {
          data: {
            attributes: {
              name: "Survival1",
              total_prize_pool: "1000",
              prize_pool_winner_share: "100",
              prize_pool_realfevr_share: "900",
              active: true,
              erc20_name: "FEVR",
              ticket_factory_contract_address: "0x456",
              ticket_locker_and_distribution_contract_address: "0x789",
              state: "incoming",
              start_date: Time.now,
              end_date: Time.now,
              min_deck_tier: 1,
              max_deck_tier: 2,
              levels_count: 1,
              background_image_url: "http://google.com",
              layout_colors: ["#000000"],
              compatible_ticket_ids: [1, 2],
              stages: [{
                level: 1, prize_amount: 10, prize_type: "FEVR"
              }]
            }
          }
        }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST show" do
    context "authenticated" do
      it "returns http status ok" do
        put "/v1/survivals/#{survivals.first.uid}", headers: headers, params: {
          data: {
            attributes: {
              name: "Survival1",
              total_prize_pool: "1000",
              prize_pool_winner_share: "100",
              prize_pool_realfevr_share: "900",
              active: true,
              erc20_name: "FEVR",
              ticket_factory_contract_address: "0x456",
              ticket_locker_and_distribution_contract_address: "0x789",
              state: "incoming",
              start_date: Time.now,
              end_date: Time.now,
              min_deck_tier: 1,
              max_deck_tier: 2,
              levels_count: 1,
              background_image_url: "http://google.com",
              layout_colors: ["#000000"],
              compatible_ticket_ids: [1, 2],
              stages: [{
                level: 1, prize_amount: 10, prize_type: "FEVR"
              }]
            }
          }
        }

        expect(response).to have_http_status(:success)
      end
    end

    context "not authenticated" do
      it "returns http status forbidden" do
        put "/v1/survivals/#{survivals.first.uid}", params: {
          data: {
            attributes: {
              name: "Survival1",
              total_prize_pool: "1000",
              prize_pool_winner_share: "100",
              prize_pool_realfevr_share: "900",
              active: true,
              erc20_name: "FEVR",
              ticket_factory_contract_address: "0x456",
              ticket_locker_and_distribution_contract_address: "0x789",
              state: "incoming",
              start_date: Time.now,
              end_date: Time.now,
              min_deck_tier: 1,
              max_deck_tier: 2,
              levels_count: 1,
              background_image_url: "http://google.com",
              layout_colors: ["#000000"],
              compatible_ticket_ids: [1, 2],
              stages: [{
                level: 1, prize_amount: 10, prize_type: "FEVR"
              }]
            }
          }
        }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /v1/survivals/:uid" do
    context "when authenticated" do
      it "returns http success" do
        delete "/v1/survivals/#{survivals.first.uid}", headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        delete "/v1/survivals/#{survivals.first.uid}"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  # it 'only accept allowed paramaters' do
  #   ActionController::Parameters.permit_all_parameters = true
  #   filter_parameters = ActionController::Parameters.new({ key: '202022', username: 'luis', wallet_addr: '0x123' })
  #   params = ActionController::Parameters.new({ page: '1',
  #                                               order: 'current_position_desc',
  #                                               per_page: '100',
  #                                               filter: filter_parameters })

  #   expect(HTTParty).to receive(:get).with(
  #     "#{leaderboards_api_base_url}/leaderboards/battle_arena/",
  #     { query: params }.merge(headers_leaderboards_api)
  #   )

  #   get '/leaderboards/battle_arena?not_allowed=123&page=1&order=current_position_desc&per_page=100&filter[key]=202022&filter[username]=luis&filter[wallet_addr]=0x123&filter[not_allowed]=123',
  #       headers: headers
  # end
  # end
end
