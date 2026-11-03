require 'minitest/autorun'
require_relative 'setup'

class ProjectSlugTest < Minitest::Test
  def setup
    Project.delete_all
    @docs = Project.create!(account_id: 1, slug: 'docs')
  end

  def test_same_account_clash_ignores_case
    row = Project.new(account_id: 1, slug: 'DOCS')
    refute row.valid?
    assert row.errors[:slug].any?
  end

  def test_other_account_may_reuse_slug
    assert Project.new(account_id: 2, slug: 'docs').valid?
  end

  def test_existing_project_can_be_saved_again
    assert @docs.update(account_id: 1)
  end

  def test_blank_slug_is_invalid
    ['', '   ', nil].each do |slug|
      row = Project.new(account_id: 1, slug: slug)
      refute row.valid?, "accepted #{slug.inspect}"
      assert row.errors[:slug].any?
    end
  end
end
