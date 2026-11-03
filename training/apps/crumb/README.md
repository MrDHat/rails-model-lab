# Crumb

Order management for a Paris bakery. Customers order through a mobile app
that talks to the JSON API under /api (authenticated with an API client
token); staff use the HTML pages under /admin. When an order is ready, the
customer gets a text message.

    bin/rails db:setup   # schema and seed data
    bin/rails test
