The API key travels in the query string (`?api_key=...`), so it ends up in
proxy and server logs. The new mobile app sends it in a header instead,
`Authorization: Bearer KEY`. Accept the key from that header on every API
endpoint, and keep accepting `api_key` until the old app versions are gone.
A request without a valid key gets a 401 with the header
`WWW-Authenticate: Token realm="Crumb"`.
