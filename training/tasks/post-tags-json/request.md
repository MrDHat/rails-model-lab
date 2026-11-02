Posts keep their tags in a text column. Code should read post.tags as an array
of strings, assign an array, and get [] for a post with no tags. Tags must be
stored as JSON (other services read it), for example ["ruby","rails"]; a post
with no tags may leave the column NULL.
Keep the schema unchanged.
