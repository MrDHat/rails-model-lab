# Team tickets API

Run `bin/rails db:prepare` and `bin/rails test`.

GET /tickets returns a JSON array ordered by ID. GET /tickets/:id and
PATCH /tickets/:id return a JSON ticket containing id, team_id, title, status.
Writes nest fields under ticket. Title must be nonblank; status is open or
closed. Successful requests return 200, missing tickets return 404, invalid
edits return 422 with a nonempty errors object.

The development identity fixture reads X-Team-ID from the trusted gateway.
A missing or unknown team returns 401. Use the existing current_team helper;
implementing authentication is outside this exercise. Teams have many tickets.
