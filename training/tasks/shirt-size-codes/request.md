The shirts.size column stores one-letter codes: "s", "m" and "l". Code should
work with the names small, medium and large: shirt.size returns "medium",
Shirt.create!(size: :large) stores "l", shirt.small? and the other
predicates work, and Shirt.large returns all large shirts. The stored codes
must stay one letter. Keep the schema unchanged.
