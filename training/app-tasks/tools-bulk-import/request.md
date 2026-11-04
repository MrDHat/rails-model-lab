The makerspace is merging in another shed's inventory of several thousand
tools. Add `POST /tools/import`, which takes a JSON body like

    {"tools": [{"name": "Rake", "serial": "RK-1", "category": "Garden", "daily_fee_cents": 100}, ...]}

with the category given by name, and responds with JSON `{"imported": N}`,
the number of tools it added. Rows whose serial is already in use, or whose
category doesn't exist, are skipped. The import has to write all the new
tools with a single INSERT statement, however many rows there are, and the
new tools get their created and updated times like any other tool.
