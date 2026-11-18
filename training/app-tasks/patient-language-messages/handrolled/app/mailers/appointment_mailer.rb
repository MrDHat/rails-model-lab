class AppointmentMailer < ApplicationMailer
  def confirmation(appointment)
    @appointment = appointment
    @patient = appointment.patient
    previous, I18n.locale = I18n.locale, @patient.locale
    mail to: @patient.email, subject: t(".subject", time: l(appointment.starts_at, format: :short))
  ensure
    I18n.locale = previous
  end

  def cancellation(appointment)
    @appointment = appointment
    @patient = appointment.patient
    previous, I18n.locale = I18n.locale, @patient.locale
    mail to: @patient.email, subject: t(".subject", time: l(appointment.starts_at, format: :short))
  ensure
    I18n.locale = previous
  end
end
