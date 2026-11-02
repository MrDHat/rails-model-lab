require 'minitest/autorun'
require_relative 'setup'

class SurveyLimitTest < Minitest::Test
  def setup
    Question.delete_all
    Survey.delete_all
  end

  def rows(count) = Array.new(count) { { text: "Q#{_1}" } }

  def test_five_rows_save
    Survey.create!(title: 'Ok', questions_attributes: rows(5))
    assert_equal 5, Question.count
  end

  def test_six_rows_raise_and_save_nothing
    assert_raises(StandardError) { Survey.create!(title: 'Too many', questions_attributes: rows(6)) }
    assert_equal 0, Survey.count
    assert_equal 0, Question.count
  end
end
