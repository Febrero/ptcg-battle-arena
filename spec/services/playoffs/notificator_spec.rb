require "rails_helper"

RSpec.describe Playoffs::Notificator do
  let!(:create_ticket) { create(:ticket, bc_ticket_id: 1, ticket_factory_contract_address: "0x123") }
  let(:playoff) { create(:playoff) }
  let(:message_type) { :state }
  let(:message_details) { {additional_info: "Some additional information"} }

  describe "#call" do
    before do
      allow(Playoff).to receive(:find_by).with(uid: playoff.uid.to_i).and_return(playoff)
      allow(Rabbitmq::PlayoffsPublisher).to receive(:send)
    end

    it "sends the correct message to RabbitMQ" do
      allow_any_instance_of(Playoffs::Notificator).to receive(:state).and_return({uid: playoff.uid, state: playoff.state})

      Playoffs::Notificator.call(playoff.uid, :state, message_details)

      expect(Rabbitmq::PlayoffsPublisher).to have_received(:send).with("state", {uid: playoff.uid, state: playoff.state}.to_json)
    end

    context "when message_type is a string" do
      let(:message_type) { "round" }

      it "calls the corresponding method and sends the correct message to RabbitMQ" do
        allow_any_instance_of(Playoffs::Notificator).to receive(:round).and_return({uid: playoff.uid, round: playoff.current_round})

        Playoffs::Notificator.call(playoff.uid, message_type, message_details)

        expect(Rabbitmq::PlayoffsPublisher).to have_received(:send).with("round", {uid: playoff.uid, round: playoff.current_round}.to_json)
      end
    end

    context "when message_type is not a recognized type" do
      let(:message_type) { :invalid }

      it "does not call any method and does not send a message to RabbitMQ" do
        Playoffs::Notificator.call(playoff.uid, message_type, message_details)
        expect(Rabbitmq::PlayoffsPublisher).not_to have_received(:send)
      end
    end
  end
end
