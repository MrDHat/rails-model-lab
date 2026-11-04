Add passwordless sign-in links, keeping today's sign-in by email as it is.

- `POST /session/link` with an `email` param emails that member a sign-in
  link, sent straight away by `SessionMailer.sign_in_link(member)`. Whether or
  not a member has that email, it redirects to the sign-in page with the
  notice "Check your email", so the form can't be used to find out who's a
  member.
- The email's text contains the link, `http://example.com/session/link?token=...`
  in tests. Opening `GET /session/link?token=...` signs the member in and
  redirects to the tools list.
- A link works for 15 minutes, and only once: after a member signs in with a
  link, that link and any link sent to them earlier stop working. A link that
  doesn't work redirects to the sign-in page with the alert "That link has
  expired" and signs nobody in.
