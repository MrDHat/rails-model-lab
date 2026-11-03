class ReportJob < ActiveJob::Base
  queue_as :priority

  def perform(account_id, plan); end
end
