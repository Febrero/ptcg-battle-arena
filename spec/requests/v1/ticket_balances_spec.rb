require "rails_helper"

RSpec.describe "V1::TicketBalances", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  let!(:ticket) {
    create(
      :ticket,
      name: "Lisbon",
      description: "Ticket for lisbon",
      expiration_date: 1.year.from_now,
      base_price: 10000,
      image_url: "https://google.com",
      available_quantities: [1],
      ticket_factory_contract_address: "0xCBEEDB880961503d85B4052f7F53Ea93f6d8dc2D",
      bc_ticket_id: 1
    )
  }
  let!(:ticket_balance) {
    create(
      :ticket_balance,
      wallet_addr: "x0sad1w",
      deposited: 2,
      balance: 3,
      ticket: ticket
    )
  }

  describe "GET /user" do
    context "Authenticated" do
      before do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        get "/v1/ticket_balances/user", headers: headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "Not authenticated" do
      before do
        get "/v1/ticket_balances/user"
      end

      it "returns http unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /v1/spend" do
    context "Authenticated" do
      before do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        put "/v1/ticket_balances/spend", headers: headers, params: {
          game_id: "1029129ej10e13j",
          players: [
            {
              bc_ticket_id: 1,
              wallet_addr: "x0sad1w",
              ticket_factory_contract_address: "0xCBEEDB880961503d85B4052f7F53Ea93f6d8dc2D"
            },
            {
              bc_ticket_id: 1,
              wallet_addr: "x0sad1w",
              ticket_factory_contract_address: "0xCBEEDB880961503d85B4052f7F53Ea93f6d8dc2D"
            }
          ]
        }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "Not authenticated" do
      before do
        get "/v1/ticket_balances/user"
      end

      it "returns http unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
