BookList.lines returns strings like "Dune by Frank Herbert" for every book,
ordered by title. It currently runs one query per book. It must run at most
two queries however many books there are. Keep the schema unchanged.
