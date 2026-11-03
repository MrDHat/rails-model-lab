require "test_helper"

class OverdueSummaryBulkTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    Loan.delete_all
    ActionMailer::Base.deliveries.clear
    travel_to Time.utc(2026, 5, 10, 2)
    tools = Array.new(4) { Tool.create!(name: "Clamp #{_1}", serial: "CL-#{_1}", category: categories(:power)) }
    lend = ->(member, tool, due_on) { tool.loans.create!(member: member, due_on: due_on) }
    lend.(members(:ana), tools[0], Date.new(2026, 5, 1))
    lend.(members(:ana), tools[1], Date.new(2026, 5, 8))
    lend.(members(:ana), tools[2], Date.new(2026, 5, 12))
    lend.(members(:bo), tools[3], Date.new(2026, 5, 9))
    lend.(members(:bo), tools(:drill), Date.new(2026, 5, 2)).return!
  end

  teardown { travel_back }

  test "one email per member with overdue loans" do
    assert_enqueued_emails 2 do
      OverdueSweepJob.perform_now
    end
  end

  test "each email lists the member's overdue tools" do
    perform_enqueued_jobs { OverdueSweepJob.perform_now }
    mails = ActionMailer::Base.deliveries.index_by { _1.to.sole }
    assert_equal ["ana@example.com", "bo@example.com"], mails.keys.sort
    assert_equal "2 tools overdue", mails["ana@example.com"].subject
    assert_equal "1 tool overdue", mails["bo@example.com"].subject
    ana = mails["ana@example.com"].body.to_s
    assert_includes ana, "Clamp 0, due May 01, 2026"
    assert_includes ana, "Clamp 1, due May 08, 2026"
    assert_not_includes ana, "Clamp 2"
    assert_includes mails["bo@example.com"].body.to_s, "Clamp 3, due May 09, 2026"
  end

  test "the single-loan email is unchanged" do
    mail = LoanMailer.overdue(members(:bo).loans.open.sole)
    assert_equal "Clamp 3 was due May 09, 2026", mail.subject
  end
end
