# Save edits to loaded child records with the parent

One Rails exercise. It is not from the benchmark and is not training data until
training is separately approved. See [the task format](../../README.md).

Turn on `autosave` for the association so changed children are validated and saved with the parent.

Full credit needs `autosave: true` on `line_items`. `handrolled.rb` passes the behaviour tests with a callback that saves changed children plus a custom validation, so it gets 0.1.

Written from these public references:

- https://api.rubyonrails.org/v8.1.3/classes/ActiveRecord/AutosaveAssociation.html
