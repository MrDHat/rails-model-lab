class Payment < ActiveRecord::Base
  enum :status, { pending: 0, settled: 10, failed: 20 }, prefix: true, default: :pending
  validates :status, presence: true
  validate { errors.add(:status, :inclusion) if @unknown_status }

  def status=(value)
    @unknown_status = nil
    super
  rescue ArgumentError
    @unknown_status = value
    super(nil)
  end
end
