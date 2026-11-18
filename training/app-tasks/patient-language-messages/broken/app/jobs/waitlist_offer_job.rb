# Offers a freed slot to a patient on the waitlist.
class WaitlistOfferJob < ApplicationJob
  queue_as :default

  def perform(entry, starts_at)
    I18n.locale = entry.patient.locale
    SmsGateway.deliver(
      to: PhoneNumber.e164(entry.patient.phone),
      body: I18n.t("sms.waitlist_offer", name: entry.patient.first_name, practitioner: entry.practitioner.name,
                                         time: I18n.l(starts_at.in_time_zone, format: :short))
    )
  end
end
