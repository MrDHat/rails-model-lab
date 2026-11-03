The shirts.size column stores one-letter codes: "s", "m" and "l". Code should
work with the names small, medium and large instead: shirt.size returns
"medium", Shirt.create!(size: :large) stores "l", and
Shirt.where(size: :large) finds the large shirts. The stored codes must stay
one letter. Keep the schema unchanged.
