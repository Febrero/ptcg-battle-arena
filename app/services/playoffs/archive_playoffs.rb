module Playoffs
  class ArchivePlayoffs < ApplicationService
    def call
      archive_finished_games
      archive_canceled_games
    end

    def archive_finished_games
      Playoff.where(:state => "finished", :finished_at.lte => 6.hours.ago).each do |playoff|
        playoff.active = false
        playoff.archive!
      end
    end

    def archive_canceled_games
      Playoff.where(:state => "canceled", :canceled_at.lte => 1.hours.ago).each do |playoff|
        playoff.active = false
        playoff.archive!
      end
    end
  end
end
