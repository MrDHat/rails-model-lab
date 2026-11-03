SettleJob(payment_id) calls Gateway.settle and already retries GatewayDown
twice in total. When it finally gives up, or when the id is invalid
(ArgumentError, which should never be retried), add [payment_id, error class
name] to FailureLog.entries so support can follow up. Successful jobs and
retries in progress must not be logged.
