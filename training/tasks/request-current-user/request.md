Notes should record who wrote them without every caller passing the user.
Add a Current object: Current.user = name sets the user for the current
request, Current.user reads it, and Current.reset clears it between requests.
Requests run on separate threads and must never see each other's user.
Note.create! fills author from Current.user. Keep the schema unchanged.
