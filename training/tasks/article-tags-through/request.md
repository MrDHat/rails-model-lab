Entries are labelled through the labelings join table. entry.labels
currently returns a plain array, so callers can't chain queries. Make
entry.labels a relation callers can chain, such as
entry.labels.where(name: 'ruby').exists? and entry.labels.order(:name).
Keep the schema unchanged.
