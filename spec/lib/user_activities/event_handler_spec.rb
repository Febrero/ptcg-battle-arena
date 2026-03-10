require "rails_helper"

RSpec.describe UserActivities::EventHandler do
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
    it "raises NotImplementedError when status is not implemented" do
      expect { described_class.new(fake_event).status }.to raise_error(NotImplementedError)
    end

    it "raises NotImplementedError when reward_type is not implemented" do
      expect { described_class.new(fake_event).reward_type }.to raise_error(NotImplementedError)
    end

    it "raises NotImplementedError when source is not implemented" do
      expect { described_class.new(fake_event).source }.to raise_error(NotImplementedError)
    end

    it "raises NotImplementedError when source_key is not implemented" do
      expect { described_class.new(fake_event).source_key }.to raise_error(NotImplementedError)
    end

    it "raises NotImplementedError when value is not implemented" do
      expect { described_class.new(fake_event).value }.to raise_error(NotImplementedError)
    end

    it "raises NotImplementedError when user_activity is not implemented" do
      expect { described_class.new(fake_event).user_activity }.to raise_error(NotImplementedError)
    end
  end
end
