LeadImport.call(rows) takes rows like { email:, source: } from a trade-show
scan. Add emails we don't have. Emails we already have must be left exactly
as they are (keep their original source). The import must be one SQL write
statement. Keep the schema unchanged.
