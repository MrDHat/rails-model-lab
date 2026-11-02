require 'minitest/autorun'
require_relative 'setup'

class TodoStateTest < Minitest::Test
  def setup
    Todo.delete_all
  end

  def test_names_and_bang_method
    row = Todo.create!(state: :doing)
    assert_equal 'doing', row.state
    row.done!
    assert Todo.find(row.id).done?
    assert_equal 2, Todo.connection.select_value("SELECT state FROM todos WHERE id = #{row.id}")
  end

  def test_positive_and_negative_scopes
    open_one = Todo.create!(state: :todo)
    finished = Todo.create!(state: :done)
    assert_equal [finished.id], Todo.done.pluck(:id)
    assert_equal [open_one.id], Todo.not_done.pluck(:id)
  end
end
