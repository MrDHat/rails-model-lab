Add Issue.by_urgency, returning issues ordered urgent, high, normal, low, and
by id within the same priority. The stored codes are legacy and not in that
order (normal 0, low 1, urgent 2, high 3), and must not change. The result
must stay a relation so callers can chain .limit. Keep the schema unchanged.
