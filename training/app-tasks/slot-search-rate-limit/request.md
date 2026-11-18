Someone is scraping practitioners' free times through the slot search
(`GET /api/slots`) with one of our app builds' tokens, thousands of requests
a minute, and the API slows down for everyone.

Limit slot searches to 30 a minute for each API client. Past the limit,
answer 429 with JSON `{"errors": ["Too many slot searches, try again in a
minute"]}`. Other clients, and the other API endpoints, aren't affected, and
the client can search again once the minute is up.
