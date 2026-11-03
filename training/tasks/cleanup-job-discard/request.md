CleanupJob.perform_later(upload_id) marks an upload as cleaned. Uploads are
sometimes deleted before the job runs, and those jobs currently fail and land
in the error queue. When the upload no longer exists the job should finish
quietly: no error and no retry. Keep the schema unchanged.
