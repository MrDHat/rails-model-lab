Board pages are cached by the board's updated_at, so they go stale when a card
changes. Creating, updating or destroying a card must bump its board's
updated_at. Keep the schema unchanged.
