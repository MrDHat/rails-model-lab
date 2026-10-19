# Submit expense claims

Employees use this app to prepare expense claims before sending them for
approval. They should be able to save an incomplete draft and finish it later.
Currently, incomplete claims can also be submitted.

Please fix the claim creation and editing flows so that:

- Drafts can still be saved without a merchant, amount, or expense date.
- A submitted claim must have a merchant containing something other than
  whitespace, an amount greater than zero, and an expense date.
- These rules apply both when creating a submitted claim and when editing an
  existing submitted claim or submitting a draft.
- If a save is rejected, the user sees a validation error and the previously
  saved claim stays unchanged.

Keep the existing JSON API and its response conventions working.
