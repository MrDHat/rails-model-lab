require "test_helper"

class WaitlistTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup { travel_to Time.utc(2026, 6, 14, 12) }
  teardown { travel_back }

  test "a cancellation offers the slot to the longest-waiting patient" do
    assert_enqueued_with(job: WaitlistOfferJob, args: [waitlist_entries(:tom_wants_ana), appointments(:julia_monday).starts_at]) do
      appointments(:julia_monday).cancel!(reason: "Away")
    end
    assert_equal Time.current, waitlist_entries(:tom_wants_ana).reload.offered_at
  end

  test "only for the same treatment" do
    assert_no_enqueued_jobs(only: WaitlistOfferJob) { appointments(:marcos_monday).cancel!(reason: "Away") }
  end

  test "each entry is offered once" do
    appointments(:julia_monday).cancel!(reason: "Away")
    other = Appointment.create!(patient: patients(:julia), practitioner: practitioners(:ana), treatment: treatments(:physio),
                                starts_at: Time.utc(2026, 6, 17, 12))
    assert_no_enqueued_jobs(only: WaitlistOfferJob) { other.cancel!(reason: "Away") }
  end
end
