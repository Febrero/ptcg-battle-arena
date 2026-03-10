require "rails_helper"

RSpec.describe SurvivalsSearch, type: :search_query do
  before do
    create_list(:survival, 2, :incoming)
    create_list(:survival, 3, :active)
    create_list(:survival, 4, :closed)
    create_list(:survival, 5, :archived)
  end

  subject { SurvivalsSearch }

  describe "query" do
    it "should return an array containing the pagination data" do
      expect(subject.new(ActionController::Parameters.new({})).search).to be_a(Array)
    end

    it "should return all records" do
      expect(subject.new(ActionController::Parameters.new({})).search.last).to eq(Survival.count)
    end

    context "filtering" do
      it "should return all incoming records" do
        incoming_filtering = ActionController::Parameters.new({filter: {state: "incoming"}})
        expect(subject.new(incoming_filtering).search.last).to eq(2)
      end

      it "should return all active records" do
        active_filtering = ActionController::Parameters.new({filter: {state: "active"}})
        expect(subject.new(active_filtering).search.last).to eq(3)
      end

      it "should return all closed records" do
        closed_filtering = ActionController::Parameters.new({filter: {state: "closed"}})
        expect(subject.new(closed_filtering).search.last).to eq(4)
      end

      it "should return all archived records" do
        archived_filtering = ActionController::Parameters.new({filter: {state: "archived"}})
        expect(subject.new(archived_filtering).search.last).to eq(5)
      end
    end

    context "pagination" do
      it "should process the page param" do
        page_filtering = ActionController::Parameters.new({page: {page: 3, per_page: 5}})
        search_made = subject.new(page_filtering).search

        expect(search_made[0].count).to eq(4)
        expect(search_made[1]).to eq(3)
      end

      it "should process the per_page param" do
        page_filtering = ActionController::Parameters.new({page: {per_page: 3}})
        search_made = subject.new(page_filtering).search

        expect(search_made[0].count).to eq(3)
        expect(search_made[2]).to eq(3)
      end
    end

    context "sorting" do
      it "should sort by uid desc" do
        ordering_params = ActionController::Parameters.new({filter: {state: "incoming"}, sort: "-uid"})
        survivals_array = subject.new(ordering_params).search.first

        expect(survivals_array.first.uid).to be > survivals_array.last.uid
      end

      it "should sort by uid asc" do
        ordering_params = ActionController::Parameters.new({filter: {state: "incoming"}, sort: "uid"})
        survivals_array = subject.new(ordering_params).search.first

        expect(survivals_array.first.uid).to be < survivals_array.last.uid
      end

      it "should sort by start_date desc" do
        ordering_params = ActionController::Parameters.new({filter: {state: "incoming"}, sort: "-start_date"})
        survivals_array = subject.new(ordering_params).search.first

        expect(survivals_array.first.start_date).to be > survivals_array.last.start_date
      end

      it "should sort by start_date asc" do
        ordering_params = ActionController::Parameters.new({filter: {state: "incoming"}, sort: "start_date"})
        survivals_array = subject.new(ordering_params).search.first

        expect(survivals_array.first.start_date).to be < survivals_array.last.start_date
      end
    end
  end
end
