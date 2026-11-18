When the desk app or an old newsroom tab sends a status the app doesn't know
(the desk app sends "live"; old tabs still have "killed"), saving a story
crashes with a 500. Treat it like any other invalid input: the newsroom form
comes back (422) saying "Status is not included in the list", the desk app gets
a 422 with that message in `errors`, and nothing from that save is kept.
