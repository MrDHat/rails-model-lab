Spam bots post comments in bursts, and moderators delete them within seconds.
When a comment is deleted before its alert email to the story's authors has
gone out, the alert job fails with "Couldn't find Comment", and the queue
keeps retrying it and paging whoever is on call. If the comment is gone by the
time the job runs, the job should do nothing and finish quietly.
