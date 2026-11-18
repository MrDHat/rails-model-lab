# When a booked slot frees up, the longest-waiting patient whose window covers
# that day is offered it by text.
module Waitlist
  def self.offer_freed_slot(appointment)
    return if appointment.starts_at <= Time.current

    entry = appointment.practitioner.waitlist_entries.waiting
                       .where(treatment: appointment.treatment)
                       .covering(appointment.starts_at.to_date)
                       .order(:created_at).first
    return unless entry

    entry.update!(offered_at: Time.current)
    WaitlistOfferJob.perform_later(entry, appointment.starts_at)
  end
end
