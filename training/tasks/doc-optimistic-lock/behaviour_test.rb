require 'minitest/autorun'
require_relative 'setup'

class PageLockTest < Minitest::Test
  def test_stale_save_raises
    id = Page.create!(title: 'Start').id
    mine = Page.find(id)
    theirs = Page.find(id)
    theirs.update!(title: 'Theirs')
    assert_raises(ActiveRecord::StaleObjectError) { mine.update!(title: 'Mine') }
    assert_equal 'Theirs', Page.find(id).title
  end

  def test_repeated_saves_from_fresh_copy
    page = Page.create!(title: 'A')
    page.update!(title: 'B')
    page.update!(title: 'C')
    assert_equal 'C', page.reload.title
  end
end
