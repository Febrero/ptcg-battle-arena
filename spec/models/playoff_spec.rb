require "rails_helper"

RSpec.describe Playoff, type: :model do
  let!(:ticket) { create(:ticket) }
  let!(:playoff) { create(:playoff, current_round: 1, open_date: Time.now.utc - 1.minutes, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_factory_contract_address: ticket.ticket_factory_contract_address) }
  let!(:teams) {
    if playoff.opened?
      create_list(:playoffs_team, 8, playoff: playoff, ticket_id: ticket.bc_ticket_id.to_s)
    end
  }
  let!(:rounds) {
    create(:playoffs_round, number: 1, playoff: playoff)
    create(:playoffs_round, number: 2, playoff: playoff)
    create(:playoffs_round, number: 3, playoff: playoff)
  }
  let!(:season) { create(:season, active: true) }

  subject { described_class.new(automatic_advance: false, uid: 1) }

  describe "indexes" do
    #   it { is_expected.to have_index_for(state: 1).with_options(name: "state_index", background: true, sparse: true) }
  end

  describe "validations" do
    # it { is_expected.to validate(:validate_max_teams) }
    it { is_expected.to validate_presence_of(:open_date) }
    it { is_expected.to validate_presence_of(:min_deck_tier) }
    it { is_expected.to validate_presence_of(:total_prize_pool) }
    it { is_expected.to validate_presence_of(:compatible_ticket_ids) }
  end

  describe "associations" do
    it { is_expected.to have_many(:teams) }
    it { is_expected.to have_many(:brackets) }
    it { is_expected.to belong_to(:prize_config) }
  end

  describe "state machine" do
    before do
      allow(Playoffs::Notificator).to receive(:call)
      allow(Playoffs::GeneratePrizes).to receive(:call)
      allow(Playoffs::RegisterPrizeOnTeamAndSendToLeaderboards).to receive(:call)
      allow(Playoffs::GeneratePositions).to receive(:call)
    end
    it {
      playoff.state = "upcoming"
      playoff.save!
      expect(playoff).to transition_from(:upcoming).to(:opened).on_event(:open)
    }
    it {
      playoff.state = "opened"
      playoff.save!
      expect(playoff).to transition_from(:opened).to(:warmup).on_event(:pregame)
    }
    it {
      expect(subject).to transition_from(:warmup).to(:ongoing).on_event(:start)
    }
    it { expect(playoff).to transition_from(:opened).to(:canceled).on_event(:cancel) }

    it {
      expect(playoff.reload).to transition_from(:admin_pending).to(:finished).on_event(:finish)
    }
    it {
      expect(playoff.reload).to transition_from(:admin_pending).to(:finished).on_event(:finish)
    }

    it { expect(playoff).to transition_from(:ongoing).to(:admin_pending).on_event(:pending) }
    it { expect(playoff).to transition_from(:finished).to(:archived).on_event(:archive) }

    context "upcoming state (initial)" do
      [:open].each do |allowed_transition|
        it { expect(subject).to allow_event(allowed_transition) }
      end

      [:pregame, :cancel, :start, :finish, :pending, :archive, :pause, :continue].each do |invalid_transition|
        it { expect(subject).to_not allow_event(invalid_transition) }
      end
    end

    context "opened state" do
      let(:playoff) { create(:playoff, :opened, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_factory_contract_address: ticket.ticket_factory_contract_address) }

      [:pregame, :cancel].each do |allowed_transition|
        it { expect(playoff).to allow_event(allowed_transition) }
      end

      [:open, :start, :finish, :pending, :archive, :pause, :continue].each do |invalid_transition|
        it { expect(playoff).to_not allow_event(invalid_transition) }
      end

      xit "should schedule ongoing event change when playoff opens" do
      end
    end

    context "warmup state" do
      let(:playoff) { create(:playoff, :warmup, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_factory_contract_address: ticket.ticket_factory_contract_address) }

      [:start].each do |allowed_transition|
        it { expect(playoff).to allow_event(allowed_transition) }
      end

      [:open, :pregame, :cancel, :finish, :pending, :archive, :pause, :continue].each do |invalid_transition|
        it { expect(playoff).to_not allow_event(invalid_transition) }
      end

      xit "should generate playoff data when the registrations' period ends" do
      end
    end

    context "ongoing state" do
      let(:playoff) { create(:playoff, :ongoing, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_factory_contract_address: ticket.ticket_factory_contract_address) }

      [:finish, :pending, :pause].each do |allowed_transition|
        it { expect(playoff).to allow_event(allowed_transition) }
      end

      [:open, :pregame, :cancel, :start, :archive, :continue].each do |invalid_transition|
        it { expect(playoff).to_not allow_event(invalid_transition) }
      end

      xit "should schedule the advance round event when the playoff starts the rounds' stage" do
      end
    end

    context "finished state" do
      let(:playoff) { create(:playoff, :finished, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_factory_contract_address: ticket.ticket_factory_contract_address) }

      [:archive].each do |allowed_transition|
        it { expect(playoff).to allow_event(allowed_transition) }
      end

      [:open, :pregame, :cancel, :start, :finish, :pending, :continue, :pause].each do |invalid_transition|
        it { expect(playoff).to_not allow_event(invalid_transition) }
      end

      xit "should generate user activities when playoff ends" do
      end
    end

    context "archived state" do
      let(:playoff) { create(:playoff, :archived, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_factory_contract_address: ticket.ticket_factory_contract_address) }

      [:open, :pregame, :start, :finish, :pending, :archive].each do |invalid_transition|
        it { expect(playoff).to_not allow_event(invalid_transition) }
      end
    end

    context "canceled state" do
      let(:playoff) { create(:playoff, :canceled, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_factory_contract_address: ticket.ticket_factory_contract_address) }

      [:open, :pregame, :cancel, :start, :finish, :pending].each do |invalid_transition|
        it { expect(playoff).to_not allow_event(invalid_transition) }
      end
    end

    context "admin_pending state" do
      let(:playoff) { create(:playoff, :admin_pending, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_factory_contract_address: ticket.ticket_factory_contract_address) }

      [:finish].each do |allowed_transition|
        it { expect(playoff).to allow_event(allowed_transition) }
      end

      [:open, :pregame, :cancel, :start, :archive, :pending, :pause, :continue].each do |invalid_transition|
        it { expect(playoff).to_not allow_event(invalid_transition) }
      end
    end

    context "troubleshooting state" do
      let(:playoff) { create(:playoff, :troubleshooting, compatible_ticket_ids: [ticket.bc_ticket_id.to_s], ticket_factory_contract_address: ticket.ticket_factory_contract_address) }

      [:continue].each do |allowed_transition|
        it { expect(playoff).to allow_event(allowed_transition) }
      end

      [:open, :pregame, :cancel, :start, :archive, :pending, :pause, :finish].each do |invalid_transition|
        it { expect(playoff).to_not allow_event(invalid_transition) }
      end
    end
  end
end
