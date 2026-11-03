Patient tax IDs are stored in plain text. Store them encrypted, so the raw
column never contains the ID and two patients with the same ID don't get the
same stored value. patient.tax_id must still read and write plain values.
Encryption keys are already configured for the app. Keep the schema; no
lookups by tax ID are needed.
