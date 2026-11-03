The articles list shows articles.comments_count, which is never updated. Keep
it correct as comments are created and destroyed through normal model calls,
without a COUNT query each time the list is shown. Keep the schema unchanged.
