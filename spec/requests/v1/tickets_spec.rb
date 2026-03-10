require "rails_helper"

RSpec.describe "V1::Tickets", type: :request, vcr: true do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key
    }
  end
  let!(:ticket) { create(:ticket, name: "Ticket X", active: true, expiration_date: 3.months.from_now, position: 2) }
  let!(:ticket2) { create(:ticket, name: "Ticket Y", active: true, expiration_date: 1.months.ago, position: 1) }
  let!(:ticket3) { create(:ticket, name: "Ticket Z", active: false, position: 3) }
  let!(:ticket3) { create(:ticket, name: "Ticket Z", active: false, position: 3) }
  let!(:ticket4) { create(:ticket, name: "Ticket Z", active: false, position: 3, zero_fees: true) }
  let!(:ticket3) { create(:ticket, name: "Ticket Z", active: true, position: 3, game_mode: "playoff") }

  describe "GET /v1/tickets" do
    context "without filters" do
      before do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        get "/v1/tickets", headers: headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns tickets ordered by position" do
        expect(json["data"].size).to eq(4)
        expect(json["data"][0]["attributes"]["position"]).to be < json["data"][1]["attributes"]["position"]
      end
    end
    context "with filters" do
      before do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        get "/v1/tickets?filters[active]=true", headers: headers
      end

      it "filter by active" do
        expect(json["data"].size).to eq(2)
      end
    end
  end

  describe "POST /v1/tickets" do
    before do
      post "/v1/tickets", headers: headers, params: {
        data: {
          attributes: {
            bc_ticket_id: 1,
            name: "Ticket X",
            description: "Bla bla bla",
            base_price: 100,
            start_date: Time.zone.now,
            expiration_date: 1.day.from_now,
            sale_expiration_date: 1.day.from_now,
            available_quantities: [1],
            image_url: "http://image_url",
            active: true,
            game_mode: "arena"
          }
        }
      }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /v1/tickets/:id" do
    before do
      put "/v1/tickets/#{ticket.id}", headers: headers, params: {
        data: {
          attributes: {
            name: "Ticket X",
            description: "Bla bla bla",
            base_price: 100,
            start_date: Time.zone.now,
            expiration_date: 1.day.from_now,
            available_quantities: [1],
            image_url: "http://image_url",
            active: true
          }
        }
      }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "updates name attribute" do
      expect(ticket.reload.name).to eq("Ticket X")
    end
  end

  describe "GET /v1/tickets/by_game_mode" do
    context "without filters" do
      before do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        get "/v1/tickets/by_game_mode", headers: headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns tickets ordered by position" do
        expect(json["arena"].size).to eq(2)
        expect(json["playoff"].size).to eq(1)
        expect(json["arena"][0]["position"]).to be < json["arena"][1]["position"]
      end
    end
  end

  describe "GET /v1/tickets/meta/:bc_ticket_id" do
    before do
      get "/v1/tickets/meta/#{ticket.bc_ticket_id}"
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /v1/tickets" do
    before do
      delete "/v1/tickets/#{ticket.id}", headers: headers
    end

    it "returns http success" do
      expect(response).to have_http_status(:no_content)
    end
  end
end
