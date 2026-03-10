module Exports
  class ExportSurvivalsActivityJob < ApplicationJob
    def perform(email, start_date, end_date)
      ExportSurvivalsActivity.call(email, start_date, end_date)
    end
  end
end
