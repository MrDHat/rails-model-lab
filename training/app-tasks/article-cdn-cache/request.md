Story pages are the busiest pages on the site, and the CDN in front of it
sends every request through to the app because the pages say they are
private. Let shared caches keep published story pages for five minutes.

Pages served to a signed-in editor (they have edit links, and can be previews
of drafts) must never be kept by a shared cache. Repeat visits should still get
a 304 when the story hasn't changed.
