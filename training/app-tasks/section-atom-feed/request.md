Readers keep asking how to follow a section in their feed reader. Add an Atom
feed at `/sections/<slug>.atom` with the section's 20 newest live stories.
Each entry needs the headline as its title, a link to the story page, the
standfirst as its summary, its published and updated times, and an author
element for each name in the byline. The feed's own updated time is the
latest of its entries' updated times.

Point feed readers at it from the section page's `<head>`, so pasting the
section's address into a feed reader finds the feed.
