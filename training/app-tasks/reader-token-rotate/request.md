Readers who lose a phone want to sign out of the app everywhere. Add
`POST /api/reader/token` for a signed-in reader: it gives them a new API
token, returns it as `api_token` in the JSON (the app saves it), and the old
token stops working straight away.
