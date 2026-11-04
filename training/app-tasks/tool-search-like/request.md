Add a search box to the tools list. `GET /tools?q=TEXT` lists only the tools
whose name contains TEXT, ignoring case; with no `q`, or a blank one, it lists
every tool as now. Members search for sizes and offers like `3_8` and `50%`,
so `%` and `_` in the search text have to match those characters literally.
