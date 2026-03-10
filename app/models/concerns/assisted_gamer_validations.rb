module AssistedGamerValidations
  extend ActiveSupport::Concern

  included do
    validate :week_days_must_be_valid
    validate :day_hours_must_be_valid
    validate :ai_mode_must_be_valid
  end

  def week_days_must_be_valid
    valid_days = Date::DAYNAMES
    return if day_hours_that_play.empty?
    unless week_days_that_play.all? { |day| valid_days.include?(day) }
      errors.add(:week_days_that_play, "must contain only valid week days")
    end
  end

  def day_hours_must_be_valid
    return if day_hours_that_play.empty?
    unless day_hours_that_play.all? { |hour| (0..23).to_a.include?(hour.to_i) }
      errors.add(:day_hours_that_play, "must contain only valid hours in a day 0 <-> 23")
    end
  end

  def ai_mode_must_be_valid
    unless ::AssistedGamer::AI_MODES.include?(ai_mode)
      errors.add(:ai_mode, "must contain a valid ai mode")
    end
  end
end
