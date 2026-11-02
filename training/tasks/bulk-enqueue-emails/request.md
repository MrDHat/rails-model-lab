Digest.send_all(user_ids) must enqueue one DigestJob per user id, with the id
as its only argument. Sends go to tens of thousands of users, so enqueue them
as one batch through the queue adapter rather than one round trip per job.
Don't run the jobs inline.
