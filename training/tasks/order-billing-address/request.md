The checkout form submits billing_address_attributes (line1, city, and id
when editing). Creating a purchase must create and link the address. Updating
with the existing address id must update that address, not create another.
Keep the schema unchanged.
