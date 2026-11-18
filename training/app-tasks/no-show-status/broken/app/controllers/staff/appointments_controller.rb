module Staff
  class AppointmentsController < BaseController
    before_action :set_appointment, only: %i[show update]

    def show
    end

    def new
      @appointment = Appointment.new(starts_at: params[:starts_at], practitioner_id: params[:practitioner_id], source: "phone")
    end

    # Reception books by phone or for walk-ins.
    def create
      attrs = params.expect(appointment: %i[patient_id practitioner_id treatment_id starts_at source notes])
      @appointment = Booking.create!(
        patient: Patient.find(attrs[:patient_id]),
        practitioner: Practitioner.find(attrs[:practitioner_id]),
        treatment: Treatment.find(attrs[:treatment_id]),
        starts_at: Time.zone.parse(attrs[:starts_at].to_s),
        source: attrs[:source].presence || "phone",
        notes: attrs[:notes]
      )
      redirect_to staff_appointment_path(@appointment), notice: "Booked."
    rescue ActiveRecord::RecordInvalid => e
      @appointment = e.record
      render :new, status: :unprocessable_entity
    end

    # PATCH with event=check_in|complete|cancel, or a new starts_at to move it.
    def update
      case params[:event]
      when "check_in" then @appointment.check_in!
      when "complete" then @appointment.complete!
      when "no_show" then @appointment.mark_no_show!
      when "cancel"
        @appointment.cancel!(reason: params[:reason].presence || "Cancelled by reception")
        AppointmentMailer.cancellation(@appointment).deliver_later
      when nil
        @appointment.reschedule!(Time.zone.parse(params.require(:starts_at)))
      else
        return redirect_to staff_appointment_path(@appointment), alert: "Unknown action."
      end
      redirect_to staff_appointment_path(@appointment), notice: "Appointment #{@appointment.status_name.humanize(capitalize: false)}."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to staff_appointment_path(@appointment), alert: e.record.errors.full_messages.to_sentence
    end

    private

    def set_appointment
      @appointment = Appointment.find(params[:id])
    end
  end
end
