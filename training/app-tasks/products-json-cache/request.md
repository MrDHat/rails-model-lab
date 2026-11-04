Every launch of the mobile app calls `GET /api/products`, and the list
rarely changes. Serve it from the app's cache store (`Rails.cache`, which all
the app servers share) instead of loading the products each time, keeping an
entry for at most 10 minutes. A change to the products (a new price or stock
level, a new product, one deactivated or deleted) must show up on the very
next request.
