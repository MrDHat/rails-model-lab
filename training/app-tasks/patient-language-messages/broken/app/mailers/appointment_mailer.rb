class AppointmentMailer < ApplicationMailer
  def confirmation(appointment)
    @appointment = appointment
    @patient = appointment.patient
    I18n.locale = @patient.locale
    mail to: @patient.email, subject: t(".subject", time: l(appointment.starts_at, format: :short))
  end

  def cancellation(appointment)
    @appointment = appointment
    @patient = appointment.patient
    I18n.locale = @patient.locale
    mail to: @patient.email, subject: t(".subject", time: l(appointment.starts_at, format: :short))
  end
end
