A member's script is hammering the borrow endpoint. Limit each signed-in
member to 5 borrow attempts per minute. Once a member is over the limit,
further attempts that minute get a 429 response with the text "Too many
borrow attempts, try again in a minute" and borrow nothing. Other members are
not affected (members often share the makerspace's wifi, so they share an IP
address), and the member can borrow again once the minute is up.
