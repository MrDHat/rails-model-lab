require "test_helper"

class LoanDueReminderTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    Loan.delete_all
    ActionMailer::Base.deliveries.clear
    @saw = Tool.create!(name: "Mitre saw", serial: "MS-042", category: categories(:power))
  end

  def borrow(due_on)
    sign_in members(:bo)
    post tool_loans_path(@saw), params: { due_on: due_on }
    members(:bo).loans.order(:id).last
  end

  def reminders = ActionMailer::Base.deliveries.select { _1.subject.to_s.start_with?("Reminder:") }

  def run_jobs_at(time) = travel_to(time) { perform_enqueued_jobs }

  test "the reminder goes out at 9:00 the day before" do
    loan = travel_to(Time.utc(2026, 5, 1, 15, 30)) { borrow(Date.new(2026, 5, 6)) }
    times = enqueued_jobs.filter_map { _1[:at] }.map { Time.at(_1).utc }
    assert_includes times.map { _1.change(usec: 0) }, Time.utc(2026, 5, 5, 9, 0)
    run_jobs_at(Time.utc(2026, 5, 5, 9, 0, 1))
    assert_equal 1, reminders.size
    mail = reminders.first
    assert_equal ["bo@example.com"], mail.to
    assert_equal "Reminder: Mitre saw is due back #{loan.due_on.to_fs(:long)}", mail.subject
    assert_includes mail.body.to_s, "Mitre saw"
    assert_includes mail.body.to_s, "MS-042"
  end

  test "no reminder once 9:00 the day before has passed" do
    travel_to(Time.utc(2026, 5, 5, 9, 30)) { borrow(Date.new(2026, 5, 6)) }
    run_jobs_at(Time.utc(2026, 5, 6, 12))
    assert_empty reminders
  end

  test "a reminder still goes out when borrowed early that morning" do
    travel_to(Time.utc(2026, 5, 5, 7, 0)) { borrow(Date.new(2026, 5, 6)) }
    run_jobs_at(Time.utc(2026, 5, 5, 9, 0, 1))
    assert_equal 1, reminders.size
  end

  test "no reminder if the tool is back first" do
    loan = travel_to(Time.utc(2026, 5, 1, 15, 30)) { borrow(Date.new(2026, 5, 6)) }
    travel_to(Time.utc(2026, 5, 3, 12)) { patch return_loan_path(loan) }
    run_jobs_at(Time.utc(2026, 5, 5, 9, 0, 1))
    assert_empty reminders
  end

  test "a failed borrow schedules nothing" do
    travel_to(Time.utc(2026, 5, 1, 15, 30)) do
      tools(:drill).loans.create!(member: members(:ana), due_on: Date.new(2026, 5, 9))
      clear_enqueued_jobs
      sign_in members(:bo)
      post tool_loans_path(tools(:drill)), params: { due_on: Date.new(2026, 5, 6) }
    end
    assert_empty enqueued_jobs
  end
end
