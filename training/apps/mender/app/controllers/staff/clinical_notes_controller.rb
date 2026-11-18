module Staff
  class ClinicalNotesController < BaseController
    before_action :set_appointment

    def create
      @appointment.create_clinical_note!(practitioner: @appointment.practitioner, body: params.require(:body))
      redirect_to staff_appointment_path(@appointment), notice: "Note saved."
    end

    def update
      note = @appointment.clinical_note
      if note.update(body: params.require(:body))
        redirect_to staff_appointment_path(@appointment), notice: "Note saved."
      else
        redirect_to staff_appointment_path(@appointment), alert: note.errors.full_messages.to_sentence
      end
    end

    def sign
      @appointment.clinical_note.sign!
      redirect_to staff_appointment_path(@appointment), notice: "Note signed."
    end

    private

    def set_appointment
      @appointment = Appointment.find(params[:appointment_id])
    end
  end
end
