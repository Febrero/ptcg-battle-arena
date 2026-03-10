module Exports
  class ExportPlayoffsActivityJob < ApplicationJob
    def perform(email, start_date, end_date)
      ExportPlayoffsActivity.call(email, start_date, end_date)
    end
  end
end
