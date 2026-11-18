module Staff
  class PatientsController < BaseController
    PER_PAGE = 50

    before_action :set_patient, only: %i[show edit update]

    def index
      @page = [params[:page].to_i, 1].max
      patients = Patient.active
      patients = params[:sort] == "appointments" ? patients.order(appointments_count: :desc, name: :asc) : patients.order(:name)
      patients = patients.search(params[:q]) if params[:q].present?
      @patients = patients.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    end

    def show
      @appointments = @patient.appointments.order(starts_at: :desc).includes(:practitioner, :treatment)
      @invoices = @patient.invoices.order(created_at: :desc)
    end

    def edit
    end

    def update
      if @patient.update(params.expect(patient: %i[name email phone birth_date locale]))
        redirect_to staff_patient_path(@patient), notice: "Saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_patient
      @patient = Patient.find(params[:id])
    end
  end
end
