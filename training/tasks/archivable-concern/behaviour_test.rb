require 'minitest/autorun'
require_relative 'setup'
require 'active_support/testing/time_helpers'

class ArchivableTest < Minitest::Test
  include ActiveSupport::Testing::TimeHelpers

  NOW = Time.utc(2026, 5, 4, 12, 30)
  EARLIER = Time.utc(2026, 1, 2, 9, 0)

  def test_scopes_and_archive
    [Note, Doc].each do |model|
      model.delete_all
      kept = model.create!
      gone = model.create!
      travel_to(NOW) { gone.archive! }
      assert_equal NOW, model.find(gone.id).archived_at
      assert_equal [gone.id], model.archived.pluck(:id)
      assert_equal [kept.id], model.active.pluck(:id)
    end
  end

  def test_archive_all_archives_only_active_records
    [Note, Doc].each do |model|
      model.delete_all
      old = model.create!(archived_at: EARLIER)
      2.times { model.create! }
      travel_to(NOW) { model.archive_all! }
      assert_equal 0, model.active.count
      assert_equal EARLIER, old.reload.archived_at
      assert_equal [NOW, NOW], model.where.not(id: old.id).pluck(:archived_at)
    end
  end
end
