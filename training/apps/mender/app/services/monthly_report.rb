# Numbers for the managers' monthly review, in clinic time.
class MonthlyReport
  attr_reader :month

  def initialize(month, location: nil)
    @month, @location = month.beginning_of_month, location
  end

  def appointments
    scope = Appointment.between(@month.in_time_zone, @month.next_month.in_time_zone)
    scope = scope.where(practitioner: @location.practitioners) if @location
    scope
  end

  def counts_by_status
    tally = appointments.pluck(:status).tally
    Appointment::STATUS_NAMES.to_h { |value, name| [name, tally.fetch(value, 0)] }
  end

  def cancellation_rate
    total = appointments.count
    total.zero? ? 0.0 : (counts_by_status["cancelled"] * 100.0 / total).round(1)
  end

  def completed_by_practitioner
    appointments.completed.joins(:practitioner).group("practitioners.name").order("practitioners.name").count
  end

  def revenue_cents
    Payment.where(received_at: @month.in_time_zone...@month.next_month.in_time_zone).sum(:amount_cents)
  end

  def invoiced_cents
    Invoice.where(status: [Invoice::ISSUED, Invoice::PAID]).issued_between(@month, @month.end_of_month).sum(:total_cents)
  end
end
