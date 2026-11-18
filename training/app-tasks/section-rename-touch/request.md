After a section is renamed in the newsroom, its stories keep showing the old
name. The app's sync (`/api/articles?updated_since=...`) never sees those
stories as changed, so the app keeps the old name, and repeat visitors to story
pages get a 304 for the page with the old name. Make renaming a section count
as a change to every story in it. Stories in other sections stay as they are.
