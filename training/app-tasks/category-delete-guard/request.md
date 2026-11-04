Deleting a category that still has tools crashes with a 500 (the database's
foreign key refuses it). Instead, the category and its tools must stay, and
the member should land back on the categories page with an alert saying the
category still has tools. Empty categories still delete as before, and code
elsewhere that calls destroy on a category with tools must get false back,
not an exception, and leave everything in place.
