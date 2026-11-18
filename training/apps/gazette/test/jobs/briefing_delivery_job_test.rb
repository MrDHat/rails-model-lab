require "test_helper"

class BriefingDeliveryJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "emails the reader the stories in the given order" do
    ids = articles(:rugby_final, :harbour_bridge).map(&:id)
    assert_emails(1) { BriefingDeliveryJob.perform_now(readers(:mere), ids) }
    body = ActionMailer::Base.deliveries.last.body.to_s
    assert_operator body.index("Hawks"), :<, body.index("Harbour Bridge")
  end

  test "skips stories taken down since" do
    articles(:rugby_final).unpublish!
    assert_no_emails { BriefingDeliveryJob.perform_now(readers(:mere), [articles(:rugby_final).id]) }
  end
end
