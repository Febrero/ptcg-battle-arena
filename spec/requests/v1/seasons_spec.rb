require "rails_helper"

RSpec.describe "V1::Seasons", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end
  let!(:season) { create(:season, name: "Season Premium") }

  describe "GET /v1/seasons" do
    context "when authenticated" do
      it "returns http success" do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        get "/v1/seasons", headers: headers
        expect(response).to have_http_status(:success)
      end

      it "return active season" do
        allow(::Auth::User).to receive(:validate_auth).with("xxx")
          .and_return({"publicAddress" => "x0sad1w"})
        get "/v1/seasons?filters[active]=true", headers: headers
        expect(json["data"][0]["attributes"]["active"]).to be(true)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/seasons"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /v1/seasons" do
    context "when authenticated" do
      it "returns http success" do
        post "/v1/seasons", headers: headers, params: {
          data: {
            attributes: {
              name: "Season X",
              start_date: DateTime.now.utc.to_i,
              end_date: nil
            }
          }
        }
        expect(response).to have_http_status(:success)
      end

      it "returns http forbidden" do
        post "/v1/seasons", params: {
          data: {
            attributes: {
              name: "Season X",
              start_date: DateTime.now.utc.to_i,
              end_date: nil
            }
          }
        }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /v1/seasons/:id" do
    context "when authenticated" do
      before do
        put "/v1/seasons/#{season.uid}", headers: headers, params: {
          data: {
            attributes: {
              name: "Season X",
              start_date: DateTime.now.utc.to_i,
              end_date: nil
            }
          }
        }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates name attribute" do
        expect(season.reload.name).to eq("Season X")
      end
    end
  end

  context "when not authenticated" do
    it "returns http forbidden" do
      put "/v1/seasons/#{season.id}", params: {
        data: {
          attributes: {
            name: "Season X",
            start_date: DateTime.now.utc.to_i,
            end_date: nil

          }
        }
      }
      expect(response).to have_http_status(:forbidden)
    end
  end

  # describe "DELETE /seasons" do
  #   context "when authenticated" do
  #     it "returns http success" do
  #       delete "/seasons/#{season.id}", headers: headers
  #       expect(response).to have_http_status(:no_content)
  #     end
  #   end

  #   context "when not authenticated" do
  #     it "returns http forbidden" do
  #       delete "/seasons/#{season.id}"
  #       expect(response).to have_http_status(:forbidden)
  #     end
  #   end
  # end
end
