The 6am briefing run takes about twenty minutes now that 40,000 readers get
it, because it puts the deliveries on the queue one job at a time. Queue them
in bulk instead: a handful of round trips to the queue, not one per reader.

When the run crashes partway and gets started again, readers who were already
queued get a second briefing. A rerun on the same day must only queue readers
who haven't had that day's briefing yet. `MorningBriefing.deliver` should still
return how many readers it queued.
