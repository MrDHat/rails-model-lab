On the tools page, show how many times each tool has been borrowed, as
"Borrowed 3 times" (or "Borrowed 1 time") in the tool's row. The page is
already slow, so adding this must not add a database query per tool. The
number must stay right as loans are created, deleted or moved to another
tool, and tools borrowed before this change must show their real totals in
production.
