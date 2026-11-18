# The monthly claims file an insurer asks for: one row per claim made for
# invoices issued that month.
class ClaimsExport
  HEADER = %w[invoice member_number treatment date amount_cents status external_ref].freeze

  def initialize(insurer, month)
    @insurer, @month = insurer, month
  end

  def filename = "claims-#{@insurer.code.downcase}-#{@month.strftime('%Y-%m')}.csv"

  def to_csv
    rows = claims.map do |claim|
      payload = claim.payload
      [payload[:invoice], payload[:member_number], payload[:treatment], payload[:date],
       claim.amount_cents, claim.status_name, claim.external_ref]
    end
    [HEADER, *rows].map { |row| row.map { csv_field(_1) }.join(",") }.join("\n") + "\n"
  end

  private

  def csv_field(value)
    text = value.to_s
    text.match?(/[",\n]/) ? "\"#{text.gsub('"', '""')}\"" : text
  end

  def claims
    @insurer.insurance_claims.joins(:invoice)
            .where(invoices: { issued_on: @month.beginning_of_month..@month.end_of_month })
            .order("invoices.number")
  end
end
