SyncJob calls Remote.fetch, which sometimes raises Timeout::Error. On a
timeout the job should try again about 30 seconds later, up to 3 attempts in
total; if the third attempt also times out, the error should be raised. Any
other error must be raised straight away without a retry.
