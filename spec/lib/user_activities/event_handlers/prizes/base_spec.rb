require "rails_helper"

RSpec.describe UserActivities::EventHandlers::Prizes::Base do
  let!(:fake_event) do
    {
      "key" => "blabla",
      "final_value" => 1,
      "state" => "approved",
      "reward_type" => "fevr",
      "game_id" => "xpto",
      "arena" => 1,
      "event_type" => "Arena",
      "wallet_addr" => "0x123"
    }
  end

  describe "methods" do
    it "raises NotImplementedError when user_activity_query is not implemented" do
      expect { described_class.new(fake_event).user_activity_query }.to raise_error(NotImplementedError)
    end
  end
end
