class ReportJob < ActiveJob::Base
  queue_as { arguments.second == 'enterprise' ? :priority : :default }

  def perform(account_id, plan); end
end
