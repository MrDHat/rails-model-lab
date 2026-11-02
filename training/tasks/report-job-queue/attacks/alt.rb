# Expected credit 0.0: routes on account id instead of plan.
class ReportJob < ActiveJob::Base
  queue_as { arguments.first == 1 ? :priority : :default }

  def perform(account_id, plan); end
end
