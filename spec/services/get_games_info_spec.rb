require "rails_helper"

RSpec.describe GetGamesInfo do
  let!(:pvp) { create(:game, :pve) }
  let!(:pve) { create(:game, :pvp) }
  let!(:lisbon) { create(:game, :arena) }
  let!(:miami) { create(:game, :arena) }

  it "returns the correct name and count of pvp" do
    result = described_class.call
    expect(result.find { |elem| elem[:name] == pvp.match_type }[:count]).to eq(1)
  end

  it "returns the correct name and count of pve" do
    result = described_class.call
    expect(result.find { |elem| elem[:name] == pvp.match_type }[:count]).to eq(1)
  end

  it "returns the correct name and count of lisbon" do
    result = described_class.call
    expect(result.find { |elem| elem[:name] == lisbon.game_mode.name }[:count]).to eq(1)
  end

  it "returns the correct name and count of miami" do
    result = described_class.call
    expect(result.find { |elem| elem[:name] == miami.game_mode.name }[:count]).to eq(1)
  end

  it "returns the correct name and count of all" do
    result = described_class.call
    expect(result.find { |elem| elem[:name] == "Total" }[:count]).to eq(4)
  end
end
