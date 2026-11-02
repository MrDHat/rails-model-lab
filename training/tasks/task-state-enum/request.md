Todo.state holds 0 (todo), 1 (doing) or 2 (done), and code compares raw
numbers everywhere. Give it named states with the same codes: todo.done?,
todo.done! (which saves), Todo.done, and Todo.not_done for everything that
isn't done. todo.state should return the name, such as "doing". Keep the
schema unchanged.
