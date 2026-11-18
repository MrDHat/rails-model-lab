module Api
  class AppointmentsController < BaseController
    def index
      patient = Patient.find(params.require(:patient_id))
      render json: patient.appointments.upcoming.active.includes(:practitioner, :treatment, :room, practitioner: :location).map(&:as_api)
    end

    def create
      appointment = Booking.create!(
        patient: Patient.find(params.require(:patient_id)),
        practitioner: Practitioner.find(params.require(:practitioner_id)),
        treatment: Treatment.active.find_by!(code: params.require(:treatment)),
        starts_at: parse_time(params.require(:starts_at)),
        source: "app",
        notes: params[:notes]
      )
      render json: appointment.as_api, status: :created
    end

    def show
      render json: Appointment.find(params[:id]).as_api
    end

    # Patients move their own appointments from the app.
    def update
      appointment = Appointment.find(params[:id])
      appointment.reschedule!(parse_time(params.require(:starts_at)))
      render json: appointment.as_api
    end

    def destroy
      appointment = Appointment.find(params[:id])
      appointment.cancel!(reason: "Cancelled in the app")
      AppointmentMailer.cancellation(appointment).deliver_later
      render json: appointment.as_api
    end
  end
end
