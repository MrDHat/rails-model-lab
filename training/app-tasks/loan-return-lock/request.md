Members double-click Return, and the two requests for the same loan race:
both load the loan while it's still open, and the second one charges the fee
again and moves `returned_at`. Make the second return wait until the first
has finished, then see that the loan is already returned and leave it as the
first return left it. Returning an open loan works as before.
