Each thread page shows its newest reply, by posted_at (replies are sometimes
imported out of order, so the highest id is not always the newest). Add
thread.latest_reply returning that reply, or nil when there are none. The
inbox lists many threads, so it must be possible to load the latest replies
for a list of threads together with Discussion.includes(:latest_reply).
Keep the schema unchanged.
