The signup form has a terms_of_service checkbox that submits "1" when ticked
and "0" otherwise. Creating a member must fail with a validation error on
terms_of_service unless the box was ticked, including when the field is
missing from the submission. The value is not stored. Members loaded from the
database and later updated must not need the checkbox. Keep the schema.
