require "rails_helper"

RSpec.describe "V1::SampleDecks", type: :request, vcr: true do
  before do
    create(:sample_deck, video_ids: [87, 137, 125, 47, 125, 18, 50, 98, 77, 128, 5, 39, 101, 128, 120, 31, 76, 5, 34, 34, 5, 41, 12, 129, 42, 117, 117, 138, 13, 8, 13, 24, 6, 124, 42, 45, 53, 48, 48, 139, 57, 94, 59, 57, 48], grey_card_ids: [161, 70, 72, 112, 103], type: "C1", serial_number: 2)
    create(:sample_deck, video_ids: [1, 5, 6, 8], grey_card_ids: [161, 70, 72, 112, 103], type: "F1", serial_number: 3)
  end

  let!(:sample_deck1) do
    create(:sample_deck, video_ids: [1, 5, 6, 8], grey_card_ids: [161, 70, 72, 112, 103], type: "A1", serial_number: 1)
  end
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end

  describe "GET /v1/show" do
    context "when authenticated" do
      before do
        create(:sample_deck, video_ids: [87, 137, 125, 47, 125, 18, 50, 98, 77, 128, 5, 39, 101, 128, 120, 31, 76, 5, 34, 34, 5, 41, 12, 129, 42, 117, 117, 138, 13, 8, 13, 24, 6, 124, 42, 45, 53, 48, 48, 139, 57, 94, 59, 57, 48], grey_card_ids: [161, 70, 72, 112, 103], type: "C1", serial_number: 2)
        create(:sample_deck, video_ids: [1, 5, 6, 8], grey_card_ids: [161, 70, 72, 112, 103], type: "F1", serial_number: 3)

        allow(::Auth::User).to receive(:validate_auth).with("xxx").and_return({"publicAddress" => "x0sad1w"})
      end

      it "returns decks with power greater or eq than 0 when stars eq 1" do
        get "/v1/sample_decks/1", headers: headers
        expect(json["data"]["attributes"]["power"]).to be >= 0
      end

      it "returns decks with power least or eq than 550 when stars eq 1" do
        get "/v1/sample_decks/1", headers: headers
        expect(json["data"]["attributes"]["power"]).to be <= 550
      end
    end

    context "when not authenticated" do
      it "returns http forbidden when authorization is not passed" do
        get "/v1/sample_decks/#{sample_deck1.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
