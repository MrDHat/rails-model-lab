require "test_helper"

class ClaimsExportTest < ActiveSupport::TestCase
  test "one row per claim on invoices issued that month" do
    export = ClaimsExport.new(insurers(:saude), Date.new(2026, 6, 1))
    assert_equal "claims-saude-2026-06.csv", export.filename
    assert_equal [ClaimsExport::HEADER, ["MND-2026-00001", "SM-0042", "PHYS", "2026-06-08", "14400", "pending", ""]],
                 export.to_csv.lines(chomp: true).map { _1.split(",", -1) }
  end

  test "other months and insurers are left out" do
    assert_equal 1, ClaimsExport.new(insurers(:saude), Date.new(2026, 5, 1)).to_csv.lines.size
    assert_equal 1, ClaimsExport.new(insurers(:vida), Date.new(2026, 6, 1)).to_csv.lines.size
  end
end
