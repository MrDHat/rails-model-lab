When staff ban a member (`member.ban!`), their open loans should be closed
too: return each one with `Loan#return!` (so the usual fee is charged) as of
the moment of the ban. It's all or nothing: if returning any of the loans
fails, `ban!` raises that error, the member isn't banned and every loan stays
as it was.
