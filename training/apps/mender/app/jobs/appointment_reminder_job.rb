# Texts the patient the day before their appointment.
class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    return unless appointment.booked?

    SmsGateway.deliver(
      to: PhoneNumber.e164(appointment.patient.phone),
      body: I18n.t("sms.reminder", name: appointment.patient.first_name, practitioner: appointment.practitioner.name,
                                   time: I18n.l(appointment.starts_at, format: :short), location: appointment.location.name)
    )
  end
end
