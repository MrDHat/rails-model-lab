The customers table has a legacy column called emailaddr that we can't rename
yet. New code should use customer.email to read and write it, including
Customer.new(email: ...) and create!. Reads of emailaddr must keep working
for old code. Keep the schema unchanged.
