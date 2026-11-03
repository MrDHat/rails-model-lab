Add Job.status_counts returning a hash such as { "queued" => 2, "failed" => 1 }
for the dashboard. There are millions of jobs, so it must not load job
records into memory. Keep the schema unchanged.
