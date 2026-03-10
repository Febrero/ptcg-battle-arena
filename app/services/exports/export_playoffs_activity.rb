module Exports
  class ExportPlayoffsActivity < ApplicationService
    def call(email, start_date, end_date)
      result = activity(start_date.to_datetime, end_date.to_datetime)

      events_fields = [:uid, :name, :has_custom_prize, :players, :open_date, :prizes_ditributed, :prizes_token, :has_been_played]
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

      ExportPlayoffsActivityMailer.send_mail(
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
      Playoff.where(admin_only: false).between(start_date: (start_date..end_date)).each_with_object({}) do |playoff, hash|
        rounds = playoff.rounds.count
        hash[:events] ||= []
        hash[:events] << {
          uid: playoff.uid,
          name: playoff.name,
          has_custom_prize: playoff.has_custom_prize,
          players: playoff.teams.count,
          open_date: playoff.open_date,
          prizes_ditributed: playoff.total_prize_pool,
          prizes_token: playoff.erc20_name_alt || playoff.erc20_name.downcase,
          has_been_played: rounds > 0
        }
        hash[:events_by_stars] ||= {}
        hash[:events_by_stars][playoff.max_deck_tier] ||= 0
        hash[:events_by_stars][playoff.max_deck_tier] += 1

        hash[:total_prizes_distributed] ||= {}
        if rounds > 0
          if playoff.erc20_name_alt
            hash[:total_prizes_distributed][playoff.erc20_name_alt] ||= 0
            hash[:total_prizes_distributed][playoff.erc20_name_alt] += playoff.total_prize_pool
          else
            hash[:total_prizes_distributed][playoff.erc20_name.downcase] ||= 0
            hash[:total_prizes_distributed][playoff.erc20_name.downcase] += playoff.total_prize_pool
          end
        end
      end
    end
  end
end
