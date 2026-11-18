module Api
  class PatientsController < BaseController
    def create
      patient = Patient.create!(params.expect(patient: %i[name email phone birth_date locale]))
      render json: patient.as_api, status: :created
    end

    def show
      render json: Patient.find(params[:id]).as_api
    end

    # The app asks for the patient's number at sign-in and finds their record by it.
    def lookup
      patient = Patient.active.find_by!(phone: params.require(:phone))
      render json: patient.as_api
    end
  end
end
