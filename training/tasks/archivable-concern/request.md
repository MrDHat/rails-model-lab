Note and Doc both have archived_at. Put shared archiving in an Archivable
module that both include: Model.archived and Model.active scopes,
record.archive! (sets archived_at to now and saves), and
Model.archive_all! which archives every active record. Keep the schema.
