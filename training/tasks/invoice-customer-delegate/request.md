Bill views call bill.client_name and bill.client_email. Bills imported from
the old system have no client, and those calls currently blow up. Return the
client's name and email, or nil when there is no client. Keep the schema
unchanged.
