require "rails_helper"

RSpec.describe PlayoffsSearch, type: :search_query do
  subject { PlayoffsSearch }

  describe "query" do
    let!(:ticket) { create(:ticket) }
    let!(:playoff1) { create(:playoff, min_xp_level: 1, max_xp_level: 2, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
    let!(:playoff2) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }

    it "should return an array containing the pagination data" do
      expect(subject.new(ActionController::Parameters.new({})).search).to be_a(Array)
    end

    context "filtering xp level" do
      let!(:ticket) { create(:ticket) }
      let!(:playoff1) { create(:playoff, min_xp_level: 1, max_xp_level: 2, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
      let!(:playoff2) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }

      it "should return playoff with non xp_level setted" do
        incoming_filtering = ActionController::Parameters.new({filter: {xp_level: 5}})
        # pp subject.new(incoming_filtering).search
        expect(subject.new(incoming_filtering).search.last).to eq(1)
      end
    end

    context "filtering xp level" do
      let!(:ticket) { create(:ticket) }
      let!(:playoff1) { create(:playoff, min_xp_level: 1, max_xp_level: 2, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
      let!(:playoff2) { create(:playoff, min_xp_level: 3, max_xp_level: 4, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
      let!(:playoff3) { create(:playoff, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }

      it "should return no playoffs out of level" do
        incoming_filtering = ActionController::Parameters.new({filter: {xp_level: 6}})
        # pp subject.new(incoming_filtering).search
        expect(subject.new(incoming_filtering).search.last).to eq(1)
      end
      it "should return playoff 1 of playoffs" do
        incoming_filtering = ActionController::Parameters.new({filter: {xp_level: 1}})

        expect(subject.new(incoming_filtering).search.last).to eq(2)
      end
    end

    context "filtering active|admin" do
      let!(:ticket) { create(:ticket) }
      let!(:playoff1) { create(:playoff, active: true, admin_only: false, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
      let!(:playoff2) { create(:playoff, active: true, admin_only: false, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }
      let!(:playoff3) { create(:playoff, active: false, admin_only: true, ticket_factory_contract_address: ticket.ticket_factory_contract_address, compatible_ticket_ids: [ticket.bc_ticket_id.to_s]) }

      it "should default filter" do
        incoming_filtering = ActionController::Parameters.new({})
        expect(subject.new(incoming_filtering).search.last).to eq(2)
      end

      it "should return empty" do
        incoming_filtering = ActionController::Parameters.new({filter: {"active" => false}})
        # also filter by admin_only: false
        expect(subject.new(incoming_filtering).search.last).to eq(0)
      end

      it "should return playoff admin_only and false" do
        incoming_filtering = ActionController::Parameters.new({filter: {"admin_only" => true, "active" => false}})

        expect(subject.new(incoming_filtering).search.last).to eq(1)
      end
    end
  end
end
