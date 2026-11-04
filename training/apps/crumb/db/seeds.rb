ApiClient.find_or_create_by!(name: "Ordering app") { _1.token = "dev-token" }
lea = Customer.find_or_create_by!(email: "lea@example.com") { |c| c.name = "Léa"; c.phone = "+33600000001" }
Product.find_or_create_by!(sku: "CRO") { |p| p.name = "Croissant"; p.price_cents = 140; p.stock = 40 }
Product.find_or_create_by!(sku: "BAG") { |p| p.name = "Baguette"; p.price_cents = 120; p.stock = 60 }
Order.place!(customer: lea, items: [{ sku: "CRO", quantity: 2 }]) if lea.orders.none?
