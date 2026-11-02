Todo.state holds 0 (todo), 1 (doing) or 2 (done), and code compares raw
numbers everywhere. Use the names with the same codes instead: todo.state
returns the name, such as "doing", Todo.create!(state: :doing) works, and
queries like Todo.where(state: :done) and Todo.where.not(state: :done) find
the right rows. Keep the schema unchanged.
