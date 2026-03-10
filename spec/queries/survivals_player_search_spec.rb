require "rails_helper"

RSpec.describe SurvivalsPlayerSearch, type: :search_query do
  let(:wallet_addr1) { "0xABCD1234" }
  let(:wallet_addr2) { "0xFOOBAR69" }

  before do
    create_list(:survival, 2, :active).each do |active_survival|
      create(:survival_player, survival: active_survival, wallet_addr: wallet_addr1)
    end

    closed_survival = create(:survival, :closed)
    create(:survival_player, survival: closed_survival, wallet_addr: wallet_addr1)
    create(:survival_player, survival: closed_survival, wallet_addr: wallet_addr2)
  end

  subject { SurvivalsPlayerSearch }

  describe "query" do
    it "should return an array containing the pagination data" do
      expect(subject.new({}).search).to be_a(Array)
    end

    it "should return all records" do
      expect(subject.new({}).search.last).to eq(SurvivalPlayer.count)
    end

    context "filtering" do
      it "should return all player's records for active survivals" do
        survival_ids = Survival.active.map(&:uid).join(",")
        active_player_records = ActionController::Parameters.new({filter: {survival_id: survival_ids}})

        expect(subject.new(active_player_records).search.last).to eq(2)
      end

      it "should return all survivals info for a given wallet_addr" do
        active_player_records = ActionController::Parameters.new({filter: {wallet_addr: wallet_addr2}})

        expect(subject.new(active_player_records).search.last).to eq(1)
      end

      it "should return all survivals info for a given wallet_addr and suvival_id" do
        survival_uid = Survival.closed.first.uid
        active_player_records = ActionController::Parameters.new({filter: {survival_id: survival_uid, wallet_addr: wallet_addr1}})

        expect(subject.new(active_player_records).search.last).to eq(1)
      end
    end

    context "pagination" do
      it "should process the page param" do
        page_filtering = ActionController::Parameters.new({page: {page: 3, per_page: 1}})
        search_made = subject.new(page_filtering).search

        expect(search_made[0].count).to eq(1)
        expect(search_made[1]).to eq(3)
      end

      it "should process the per_page param" do
        page_filtering = ActionController::Parameters.new({page: {per_page: 2}})
        search_made = subject.new(page_filtering).search

        expect(search_made[0].count).to eq(2)
        expect(search_made[2]).to eq(2)
      end
    end

    context "sorting" do
    end
  end
end
