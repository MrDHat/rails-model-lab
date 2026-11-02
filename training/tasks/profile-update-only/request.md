The account form submits profile_attributes without an id. Today each save
replaces the person's profile with a new row, which breaks links to the old
profile id. Saving must update the existing profile in place, keeping its id,
and create one only if the person has none. Keep the schema unchanged.
