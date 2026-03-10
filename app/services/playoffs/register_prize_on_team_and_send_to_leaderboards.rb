module Playoffs
  class RegisterPrizeOnTeamAndSendToLeaderboards < ApplicationService
    def call playoff_uid
      Rails.logger.info "Sending  streak event to kafka for playoff: #{playoff_uid}"
      playoff_ends = Time.now.utc
      playoff = Playoff.find_by(uid: playoff_uid)

      generator = Playoffs::GeneratePrizes.new(playoff.uid)
      generator.generate_prizes do |prize|
        team = playoff.teams.where(wallet_addr_downcased: prize[:wallet_addr].downcase).first
        sequence = 0
        prize_amount = 0.0
        if prize[:prize_awarded]
          last_sequence = Playoffs::Team.where(wallet_addr_downcased: prize[:wallet_addr].downcase).lt(playoff_ends: playoff_ends).not(playoff_id: playoff.uid).order(playoff_ends: :desc).first&.prize_sequence || 0
          sequence = last_sequence + 1
          prize_amount = playoff.get_prize_by_rounds_completed_and_number_of_players_in_round(prize[:playoff_rounds_completed], prize[:playoff_number_of_players_in_round])
        end
        team.playoff_ends = playoff_ends
        team.prize_sequence = sequence
        team.save

        # pp playoff.uid, prize[:wallet_addr], prize_amount, playoff.erc20_name, sequence
        Playoffs::SendEndPlayoffEventToLeaderboards.call(playoff.uid, prize[:wallet_addr], prize_amount, (playoff.erc20_name_alt || playoff.erc20_name), sequence)
      end
    end
  end
end
