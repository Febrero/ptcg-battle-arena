module Exports
  class ExportSurvivalsActivity < ApplicationService
    def call(email, start_date, end_date)
      result = activity(start_date.to_datetime, end_date.to_datetime)

      events_fields = [
        :uid, :name, :survival_players, :survival_entries, :min_deck_tier,
        :max_deck_tier, :start_date, :end_date, :prizes_ditributed, :prizes_token
      ]
      csv_events = CSV.generate do |csv|
        csv << events_fields
        result[:events].each do |event|
          csv << events_fields.map { |field| event[field] }
        end
      end

      events_by_stars_fields = result[:events_by_stars].keys
      csv_events_by_stars = CSV.generate do |csv|
        csv << events_by_stars_fields
        csv << events_by_stars_fields.map { |field| result[:events_by_stars][field] }
      end

      total_prizes_distributed_fields = result[:total_prizes_distributed].keys
      csv_total_prizes_distributed = CSV.generate do |csv|
        csv << total_prizes_distributed_fields
        csv << total_prizes_distributed_fields.map { |field| result[:total_prizes_distributed][field] }
      end

      ExportSurvivalsActivityMailer.send_mail(
        email,
        [
          {
            name: "events",
            file: csv_events
          },
          {
            name: "events by stars",
            file: csv_events_by_stars
          },
          {
            name: "total prizes distributed",
            file: csv_total_prizes_distributed
          }
        ]
      ).deliver_now
    end

    def activity(start_date, end_date)
      Survival.where(admin_only: false).between(start_date: (start_date..end_date)).each_with_object({}) do |survival, hash|
        prizes_distributed_sum = prizes_distributed(survival)

        hash[:events] ||= []
        hash[:events] << {
          uid: survival.uid,
          name: survival.name,
          survival_players: survival.survival_players.count,
          survival_entries: survival.survival_players.inject(0) { |sum, sp| sum + sp.entries.count },
          min_deck_tier: survival.min_deck_tier,
          max_deck_tier: survival.max_deck_tier,
          start_date: survival.start_date,
          end_date: survival.end_date,
          prizes_ditributed: prizes_distributed_sum,
          prizes_token: survival.erc20_name.downcase
        }
        hash[:events_by_stars] ||= {}
        hash[:events_by_stars][survival.max_deck_tier] ||= 0
        hash[:events_by_stars][survival.max_deck_tier] += 1

        hash[:total_prizes_distributed] ||= {}
        hash[:total_prizes_distributed][survival.erc20_name.downcase] ||= 0
        hash[:total_prizes_distributed][survival.erc20_name.downcase] += prizes_distributed_sum
      end
    end

    def prizes_distributed(survival)
      total_prize = 0

      survival.survival_players.each do |survival_player|
        survival_player.entries.each do |entry|
          stage = survival.stages.where(level: entry.levels_completed).first
          total_prize += stage.prize_amount if stage
        end
      end

      total_prize
    end
  end
end
