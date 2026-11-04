The SMS provider sometimes answers busy (`SmsGateway::Busy`), and then
`PickupNotificationJob` fails and the customer never hears their order is
ready. When the provider is busy, try again about 30 seconds later, up to 5
attempts in all. If it's still busy on the fifth attempt, email the customer
instead with a new `OrderMailer.ready(order)` (subject "Your Crumb order #ID
is ready"), sent from the job straight away, and let the job finish without
an error.
