require "rails_helper"

RSpec.describe AssistedGamerSearch, vcr: true do
  describe ".search" do
    let(:current_hour) { Time.now.hour }
    let(:current_week_day) { Date.today.strftime("%A") }
    let(:tomorrow_week_day) { Date.tomorrow.strftime("%A") }
    let!(:assisted_gamer1) {
      create(:assisted_gamer, todays_total_games_played: 2, max_daily_games: 5, day_hours_that_play: [current_hour], week_days_that_play: [current_week_day])
    }
    let!(:assisted_gamer2) {
      create(:assisted_gamer, wallet_addr: "0xqwerty", todays_total_games_played: 3, max_daily_games: 3, day_hours_that_play: [current_hour], week_days_that_play: [current_week_day])
    }
    let!(:assisted_gamer3) {
      create(:assisted_gamer, wallet_addr: "foobar", todays_total_games_played: 2, max_daily_games: 3, day_hours_that_play: [current_hour + 1], week_days_that_play: [current_week_day])
    }
    let!(:assisted_gamer4) {
      create(:assisted_gamer, wallet_addr: "x0xpto", todays_total_games_played: 2, max_daily_games: 3, day_hours_that_play: [current_hour], week_days_that_play: [tomorrow_week_day])
    }
    let!(:deck1) {
      create(
        :deck,
        :two_stars,
        wallet_addr: assisted_gamer1.wallet_addr
      )
    }
    let!(:deck2) {
      create(
        :deck,
        :two_stars,
        wallet_addr: assisted_gamer2.wallet_addr
      )
    }
    before do
      # Hammer to put decks valid...
      Deck.update_all(stars: 2, flag_status: true)
    end

    context "when searching for gamers with valid deck stars" do
      it "returns a gamer that matches all criteria" do
        result = AssistedGamerSearch.search(deck_stars: 2)
        expect(result).to be_present
        expect(result.todays_total_games_played < result.max_daily_games).to be true
        expect(result.day_hours_that_play).to eq([current_hour])
        expect(result.week_days_that_play).to eq([current_week_day])
        expect(result.id).to eq(assisted_gamer1.id)
      end
    end

    context "when searching for gamers with invalid deck or no deck" do
      it "returns null" do
        result = AssistedGamerSearch.search(deck_stars: 3)
        expect(result).to be_nil
      end
    end

    it "should filter by wallet_addr" do
      search_params = ActionController::Parameters.new({
        filter: {
          wallet_addr: "0xqwerty"
        }
      })
      collection, _, _, total = AssistedGamerSearch.new(search_params).search

      expect(total).to eq(1)
      expect(collection).to include(assisted_gamer2)
    end

    it "should filter by ai_mode" do
      search_params = ActionController::Parameters.new({
        filter: {
          ai_mode: "Ari"
        }
      })
      collection, _, _, _ = AssistedGamerSearch.new(search_params).search

      # expect(total).to eq(4)
      expect(collection).to include(assisted_gamer1, assisted_gamer2, assisted_gamer3, assisted_gamer4)
    end

    it "should filter by week_days_that_play" do
      search_params = ActionController::Parameters.new({
        filter: {
          week_days_that_play: current_week_day.to_s
        }
      })
      collection, _, _, total = AssistedGamerSearch.new(search_params).search

      expect(total).to eq(3)
      expect(collection).to include(assisted_gamer1, assisted_gamer2, assisted_gamer3)
    end

    it "should filter by day_hours_that_play" do
      search_params = ActionController::Parameters.new({
        filter: {
          day_hours_that_play: (current_hour + 1).to_s
        }
      })
      collection, _, _, total = AssistedGamerSearch.new(search_params).search

      expect(total).to eq(1)
      expect(collection).to include(assisted_gamer3)
    end
  end
end
