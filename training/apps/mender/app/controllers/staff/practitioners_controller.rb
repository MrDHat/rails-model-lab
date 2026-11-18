module Staff
  class PractitionersController < BaseController
    before_action :set_practitioner, only: %i[show edit update]
    before_action :require_manager, only: %i[edit update]

    def index
      @practitioners = Practitioner.includes(:location).order(:name)
    end

    def show
      @windows = @practitioner.availability_windows.sort_by { [_1.weekday, _1.starts_at_minute] }
      @upcoming = @practitioner.appointments.upcoming.active.includes(:patient, :treatment).limit(20)
    end

    def edit
    end

    def update
      if @practitioner.update(params.expect(practitioner: [:name, :specialty, :active, :location_id, { treatment_ids: [] }]))
        redirect_to staff_practitioner_path(@practitioner), notice: "Saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_practitioner
      @practitioner = Practitioner.find(params[:id])
    end
  end
end
