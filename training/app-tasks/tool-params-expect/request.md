Our error tracker is full of 500s from bots posting junk to the tool form:
POST /tools with tool=hello, or with no tool at all, and the same against
PATCH /tools/:id. Malformed tool parameters must get a 400 Bad Request
instead, and must not create or change anything. Normal form submissions,
including ones that fail validation, must work exactly as before.
