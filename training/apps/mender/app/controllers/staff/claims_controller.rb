module Staff
  class ClaimsController < BaseController
    before_action :require_manager, only: :export

    def index
      @claims = InsuranceClaim.includes(:insurer, :invoice).order(created_at: :desc).limit(100)
    end

    # GET /staff/claims/export?insurer=SAUDE&month=2026-06
    def export
      export = ClaimsExport.new(Insurer.find_by!(code: params.require(:insurer)), Date.strptime(params.require(:month), "%Y-%m"))
      send_data export.to_csv, filename: export.filename, type: "text/csv"
    end
  end
end
