require "rails_helper"

RSpec.describe "V1::Arenas", type: :request, vcr: true do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end
  let!(:arena) { create(:arena, name: "Arena Y") }

  describe "GET /v1/arenas" do
    context "when authenticated" do
      it "returns http success" do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        get "/v1/arenas", headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/arenas"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /v1/arenas" do
    context "when authenticated" do
      it "returns http success" do
        post "/v1/arenas", headers: headers, params: {
          data: {
            attributes: {
              name: "Arena X",
              total_prize_pool: 123,
              prize_pool_winner_share: 123,
              prize_pool_realfevr_share: 1,
              compatible_ticket_ids: [1, 4],
              active: true,
              card_image_url: "http://skewed_image_url",
              background_image_url: "http://background_image_url"
            }
          }
        }
        expect(response).to have_http_status(:success)
      end

      it "returns http forbidden" do
        post "/v1/arenas", params: {
          data: {
            attributes: {
              name: "Arena X",
              total_prize_pool: 123,
              prize_pool_winner_share: 123,
              prize_pool_realfevr_share: 1,
              compatible_ticket_ids: [1, 4],
              active: true,
              card_image_url: "http://skewed_image_url",
              background_image_url: "http://background_image_url"
            }
          }
        }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /v1/arenas/:id" do
    context "when authenticated" do
      before do
        put "/v1/arenas/#{arena.id}", headers: headers, params: {
          data: {
            attributes: {
              name: "Arena X",
              total_prize_pool: 123,
              prize_pool_winner_share: 123,
              prize_pool_realfevr_share: 1,
              compatible_ticket_ids: [1, 4],
              active: true,
              card_image_url: "http://skewed_image_url",
              background_image_url: "http://background_image_url"
            }
          }
        }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates name attribute" do
        expect(arena.reload.name).to eq("Arena X")
      end
    end
  end

  context "when not authenticated" do
    it "returns http forbidden" do
      put "/v1/arenas/#{arena.id}", params: {
        data: {
          attributes: {
            name: "Arena X",
            total_prize_pool: 123,
            prize_pool_winner_share: 123,
            prize_pool_realfevr_share: 1,
            compatible_ticket_ids: [1, 4],
            active: true,
            card_image_url: "http://skewed_image_url",
            background_image_url: "http://background_image_url"
          }
        }
      }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /v1/arenas" do
    context "when authenticated" do
      it "returns http success" do
        delete "/v1/arenas/#{arena.id}", headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        delete "/v1/arenas/#{arena.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
