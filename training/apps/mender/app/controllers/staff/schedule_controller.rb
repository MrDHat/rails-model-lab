module Staff
  # GET /staff/schedule?location_id=1&date=2026-06-15
  class ScheduleController < BaseController
    def show
      @locations = Location.order(:name)
      @location = params[:location_id] ? Location.find(params[:location_id]) : default_location
      @date = params[:date].present? ? Date.iso8601(params[:date]) : Date.current
      @schedule = Schedule.new(@location, @date)
    end

    private

    def default_location = current_staff_user.practitioner&.location || @locations.first
  end
end
