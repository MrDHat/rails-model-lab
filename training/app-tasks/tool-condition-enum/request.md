Tools need a condition: good, worn or broken. New tools start out good, and
the tool form gets a select to change it. A form post with any other
condition re-renders the form with a validation error (status 422) instead
of crashing. Broken tools can't be borrowed: the borrow is refused with the
message "Tool is broken". The tools list takes `?condition=worn` (or good, or
broken) to list only tools in that condition; an unknown value lists every
tool.
