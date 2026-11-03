Each thread page shows its newest reply, by posted_at (replies are sometimes
imported out of order, so the highest id is not always the newest). Add
thread.latest_reply returning that reply, or nil when there are none. The
inbox also needs Discussion.with_latest_reply, a relation of threads whose
latest replies are loaded up front: going through 50 threads and their latest
replies must take a fixed number of queries, not one per thread. Keep the
schema unchanged.
