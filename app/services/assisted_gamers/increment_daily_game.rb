module AssistedGamers
  class IncrementDailyGame < ApplicationService
    def call(wallet_addr)
      AssistedGamer.in(wallet_addr: wallet_addr).to_a.each do |ag|
        ag.todays_total_games_played += 1
        ag.save
      end
    end
  end
end
