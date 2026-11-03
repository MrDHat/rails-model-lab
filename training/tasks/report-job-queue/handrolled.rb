class ReportJob < ActiveJob::Base
  def queue_name
    arguments.second == 'enterprise' ? 'priority' : 'default'
  end

  def perform(account_id, plan); end
end
