module Staff
  class ReportsController < BaseController
    before_action :require_manager

    # GET /staff/report?month=2026-06&location_id=1
    def show
      month = params[:month].present? ? Date.strptime(params[:month], "%Y-%m") : Date.current
      @location = Location.find(params[:location_id]) if params[:location_id].present?
      @report = MonthlyReport.new(month, location: @location)
    end
  end
end
