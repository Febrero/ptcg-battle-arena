require "rails_helper"

RSpec.describe Rewards::FetchWalletRewards do
  context "Re-raise errors from external service" do
    it "should raise an error if the wallet was not found" do
      allow(Rewards::Reward).to receive(:where).and_raise(JsonApiClient::Errors::NotFound.new(Rails.env))

      expect { subject.call("0xXXXX", "123") }.to raise_error(Rewards::WalletNotFound)
    end

    it "should raise an error if the request timed out" do
      allow(Rewards::Reward).to receive(:where).and_raise(JsonApiClient::Errors::RequestTimeout.new(Rails.env))

      expect { subject.call("0xXXXX", "123") }.to raise_error(Rewards::ServiceConnectionTimeout)
    end

    it "should raise an error if the access was denied" do
      allow(Rewards::Reward).to receive(:where).and_raise(JsonApiClient::Errors::AccessDenied.new(Rails.env))

      expect { subject.call("0xXXXX", "123") }.to raise_error(Rewards::ServiceConnectionForbidden)
    end
  end
end
