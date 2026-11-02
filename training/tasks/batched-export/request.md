SubscriberExport.call(io) writes every subscriber's email to io, one per line,
in id order. The table is large, so no query may load more than 500 rows at
once. Keep the schema unchanged.
