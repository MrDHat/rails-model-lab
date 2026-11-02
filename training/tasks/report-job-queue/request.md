ReportJob.perform_later(account_id, plan) builds a usage report. Jobs for the
"enterprise" plan must go to the "priority" queue; all others to "default".
Callers must not have to pick the queue themselves.
