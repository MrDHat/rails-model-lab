Story URLs are made from the headline as typed, so 'Café owners say "no" to
new rules!' ends up at `/articles/café-owners-say-"no"-to-new-rules!`, which
breaks when readers share it. And a story whose headline matches an older one
can't be saved at all: "Slug has already been taken".

Make new stories' slugs plain: lowercase ASCII letters, digits and single
hyphens, made from the headline, with accents dropped (café becomes cafe) and
no hyphen at either end. When the slug is already taken, add -2, then -3 and
so on. A story keeps its slug when its headline is edited later.
