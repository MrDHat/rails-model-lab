# Stand-in for the error tracking service the newsroom uses. Everything
# reported through Rails.error ends up in ErrorTracker.reports; tests read it.
module ErrorTracker
  Report = Data.define(:error, :handled, :severity, :context, :source)

  mattr_accessor :reports, default: []

  def self.report(error, handled:, severity:, context:, source: nil)
    reports << Report.new(error:, handled:, severity:, context:, source:)
  end
end

Rails.error.subscribe(ErrorTracker)
