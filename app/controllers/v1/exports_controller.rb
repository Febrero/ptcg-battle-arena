module V1
  class ExportsController < ApplicationController
    include BasicAuth

    before_action :auth_internal_api

    api :GET, "/exports/playoffs_activity", "Export playoffs activity"
    def playoffs_activity
      Exports::ExportPlayoffsActivityJob.perform_async(params[:email], params[:start_date], params[:end_date])

      head :ok
    end

    api :GET, "/exports/survivals_activity", "Export survivals activity"
    def survivals_activity
      Exports::ExportSurvivalsActivityJob.perform_async(params[:email], params[:start_date], params[:end_date])

      head :ok
    end
  end
end
