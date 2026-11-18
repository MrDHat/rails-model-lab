Insurers' APIs are often busy at night. When an insurer answers busy, the
job that submits the claim just fails, and the claim sits as pending until
someone notices weeks later.

When the insurer is busy, try the submission again, up to 5 tries in all,
waiting at least 30 seconds before each retry. If it's still busy on the
fifth try, mark the claim failed (status 4) and record an audit event
`claim.failed` with the reason "insurer busy"; don't raise. A claim the
insurer rejects is still marked rejected straight away, without retrying.
