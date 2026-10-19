# Keep team tickets private

Teams use this app to manage their support tickets. The app already knows the
current team, but its ticket endpoints can expose and change other teams' data.

Please fix ticket listing, reading and editing so that:

- A team's list contains only its own tickets, in the existing order.
- Reading or editing another team's ticket behaves exactly like requesting a
  ticket that does not exist: return 404 and leave all saved data unchanged.
- Editing a ticket can change its title or status, but never its owning team.
  Ignore a submitted team_id while applying otherwise valid editable fields.
- Own-team reads and edits, validation errors, and existing identity handling
  continue to work through the same JSON API.

Use the app's existing current team identity. No new authentication system or
additional endpoints are needed.
