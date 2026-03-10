require "rails_helper"

RSpec.describe "V1::StandaloneBuilds", type: :request do
  let!(:headers) do
    {
      "X-RealFevr-Token": Rails.application.config.external_api_key,
      Authorization: "xxx"
    }
  end
  let!(:standalone_build_public) { create(:standalone_build, :public) }
  let!(:standalone_build_testers) { create(:standalone_build, :testers) }

  before do
    create(:standalone_build, :internal)
  end

  describe "GET /v1/standalone_builds" do
    context "when authenticated" do
      it "returns http success" do
        get "/v1/standalone_builds", headers: headers
        expect(response).to have_http_status(:success)
      end

      it "returns all results without filters" do
        get "/v1/standalone_builds", headers: headers
        expect(json["data"].size).to eq(3)
      end

      it "filters by visibility" do
        get "/v1/standalone_builds?filter[visibility]=internal", headers: headers
        expect(json["data"].size).to eq(1)
      end

      it "supports not json api pagination" do
        get "/v1/standalone_builds?page=1&per_page=1", headers: headers
        expect(json["meta"]["total_pages"]).to eq(3)
      end

      it "supports not json api pagination" do
        get "/v1/standalone_builds?per_page=1", headers: headers
        expect(json["meta"]["total_pages"]).to eq(3)
      end

      it "supports not json api pagination" do
        get "/v1/standalone_builds?page=1&per_page=5", headers: headers
        expect(json["meta"]["total_pages"]).to eq(1)
      end

      it "supports json api pagination" do
        get "/v1/standalone_builds?page[page]=1&page[per_page]=1", headers: headers
        expect(json["meta"]["total_pages"]).to eq(3)
      end

      it "supports json api pagination" do
        get "/v1/standalone_builds?page[per_page]=1", headers: headers
        expect(json["meta"]["total_pages"]).to eq(3)
      end

      it "supports json api pagination" do
        get "/v1/standalone_builds?page[per_page]=5", headers: headers
        expect(json["meta"]["total_pages"]).to eq(1)
      end

      it "supports json api pagination" do
        get "/v1/standalone_builds?page[page]=1", headers: headers
        expect(json["meta"]["total_pages"]).to eq(1)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        get "/v1/standalone_builds"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /v1/standalone_builds" do
    context "when authenticated" do
      it "returns http success" do
        post "/v1/standalone_builds", headers: headers, params: {
          data: {
            attributes: {
              version: "1.1.9",
              exe_download_url: "fake url",
              dmg_download_url: "fake url",
              force_update: false,
              notes: "fake html string",
              change_log: "fake html string",
              visibility: "public"
            }
          }
        }
        expect(response).to have_http_status(:success)
      end

      it "returns http forbidden" do
        post "/v1/standalone_builds", params: {
          data: {
            attributes: {
              version: "1.1.9",
              exe_download_url: "fake url",
              dmg_download_url: "fake url",
              force_update: false,
              notes: "fake html string",
              change_log: "fake html string",
              visibility: "public"
            }
          }
        }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /v1/standalone_build/:id" do
    context "when authenticated" do
      before do
        put "/v1/standalone_builds/#{standalone_build_public.id}", headers: headers, params: {
          data: {
            attributes: {
              visibility: "internal"
            }
          }
        }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates name attribute" do
        expect(standalone_build_public.reload.visibility).to eq("internal")
      end
    end
  end

  context "when not authenticated" do
    it "returns http forbidden" do
      put "/v1/standalone_builds/#{standalone_build_public.id}", params: {
        data: {attributes: {visibility: "internal"}}
      }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /v1/standalone_builds" do
    context "when authenticated" do
      it "returns http success" do
        delete "/v1/standalone_builds/#{standalone_build_testers.id}", headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when not authenticated" do
      it "returns http forbidden" do
        delete "/v1/standalone_builds/#{standalone_build_testers.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
