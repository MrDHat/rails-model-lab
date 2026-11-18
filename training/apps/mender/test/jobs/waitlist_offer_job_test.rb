require "test_helper"

class WaitlistOfferJobTest < ActiveJob::TestCase
  test "texts the offer" do
    WaitlistOfferJob.perform_now(waitlist_entries(:tom_wants_ana), Time.utc(2026, 6, 15, 12))
    assert_equal "+5511987650004", SmsGateway.sent.sole[:to]
    assert_includes SmsGateway.sent.sole[:body], "Ana Souza has opened on Mon 15 Jun, 09:00"
  end
end
