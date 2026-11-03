require 'minitest/autorun'
require_relative 'setup'

class SurveyLimitTest < Minitest::Test
  def setup
    Question.delete_all
    Survey.delete_all
  end

  def rows(count) = Array.new(count) { { text: "Q#{_1}" } }

  def test_up_to_five_rows_save
    (0..5).each do |count|
      survey = Survey.create!(title: "Ok #{count}", questions_attributes: rows(count))
      assert_equal count, survey.questions.count
    end
  end

  def test_more_rows_raise_and_save_nothing
    [6, 9].each do |count|
      assert_raises(StandardError) { Survey.create!(title: 'Too many', questions_attributes: rows(count)) }
    end
    assert_equal 0, Survey.count
    assert_equal 0, Question.count
  end
end
