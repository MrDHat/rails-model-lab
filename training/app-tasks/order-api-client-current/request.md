Several apps now use the API (the mobile app, a kiosk, a partner's site),
and the bakery wants to know which one each order came from. Give orders an
optional `api_client`, set to the client whose key authenticated the request
whenever an order is created during an API request. Orders get created in
several places deep inside the app (`Order.place!` and others to come), so
this must happen without passing the client down through every method call.
Orders created outside an API request, from the console, a job or the admin,
have no client, even when they're created right after an API request on the
same thread.
