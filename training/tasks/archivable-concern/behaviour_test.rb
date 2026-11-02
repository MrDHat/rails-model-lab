require 'minitest/autorun'
require_relative 'setup'

class ArchivableTest < Minitest::Test
  def test_scopes_and_archive
    [Note, Doc].each do |model|
      model.delete_all
      kept = model.create!
      gone = model.create!
      gone.archive!
      assert_equal [gone.id], model.archived.pluck(:id)
      assert_equal [kept.id], model.active.pluck(:id)
    end
  end

  def test_archive_all
    Doc.delete_all
    2.times { Doc.create! }
    Doc.archive_all!
    assert_equal 0, Doc.active.count
  end
end
