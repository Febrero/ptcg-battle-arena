require "csv"

class AssistedGamersImporter
  def self.import(file)
    CSV.foreach(file, headers: true) do |row|
      assisted_gamer_params = row.to_hash

      # Parse array fields
      assisted_gamer_params["week_days_that_play"] = assisted_gamer_params["week_days_that_play"].sub(/^(,)(.*)/, '\2').split(",")
      assisted_gamer_params["day_hours_that_play"] = assisted_gamer_params["day_hours_that_play"].split(",").map(&:to_i)

      assisted_gamer = AssistedGamer.where(wallet_addr: assisted_gamer_params["wallet_addr"]).first_or_initialize
      assisted_gamer.assign_attributes(assisted_gamer_params)

      if assisted_gamer.valid?
        assisted_gamer.save!
      else
        Rails.logger.info assisted_gamer.errors.messages
      end
    end
  end
end
