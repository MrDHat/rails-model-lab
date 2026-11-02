New tickets should start with priority 3 unless the caller gives one, and that
value must be saved. Old rows already in the database with no priority must
keep reading as nil; don't backfill them. Do not change the schema; the
database column has no default and adding one needs a migration we can't run
yet.
