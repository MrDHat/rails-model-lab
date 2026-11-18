# Gazette

The website, newsroom and mobile app backend of The Harbour Gazette, a local
paper for Wellington and the harbour towns. Readers browse the site and read
and comment in the mobile app, which talks to the JSON API under /api (each
reader has their own API token from signing up in the app). Reporters and
editors write, schedule and publish stories, moderate comments and handle
letters to the editor in the newsroom under /newsroom.

Agency copy arrives from the wire as JSON and becomes drafts for an editor to
pick up. A morning briefing email goes to readers who opted in.

Times are shown and days are counted in Wellington time (Pacific/Auckland).

    bin/rails db:setup   # schema and seed data
    bin/rails test

## Where things live

- `app/models`: the records. Stories are `Article`s; their bylines come from
  `Authorship`s, in order. `Editor`s are newsroom staff; `Reader`s are app
  users.
- `app/services`: the wire import (`WireFeed`), the morning briefing, the
  front page and the newsroom dashboard.
- `app/jobs`: scheduled publishing, the briefing, wire imports and comment
  alerts.
- `app/controllers`: the public site at the top level, `api/` for the app and
  `newsroom/` for staff.
- `config/initializers/error_tracker.rb`: a stand-in for the error tracking
  service; everything reported through `Rails.error` lands there.
