require 'minitest/autorun'
require_relative 'setup'

class TodoStateTest < Minitest::Test
  def setup
    Todo.delete_all
  end

  def stored(row)
    Todo.connection.select_value("SELECT state FROM todos WHERE id = #{row.id}")
  end

  def test_names_keep_their_codes
    { todo: 0, doing: 1, done: 2 }.each do |name, code|
      row = Todo.create!(state: name)
      assert_equal code, stored(row)
      assert_equal name.to_s, Todo.find(row.id).state
    end
  end

  def test_existing_codes_read_as_names
    row = Todo.create!(state: :todo)
    Todo.where(id: row.id).update_all(state: 1)
    assert_equal 'doing', row.reload.state
  end

  def test_queries_by_name
    open_one = Todo.create!(state: :todo)
    finished = Todo.create!(state: :done)
    assert_equal [finished.id], Todo.where(state: :done).pluck(:id)
    assert_equal [open_one.id], Todo.where.not(state: :done).pluck(:id)
  end
end
