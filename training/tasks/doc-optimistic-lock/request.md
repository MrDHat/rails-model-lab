Two people can open the same page and save over each other's edits. pages has
a revision column for this. When a page was saved by someone else after you
loaded it, your save must raise ActiveRecord::StaleObjectError and leave the
other person's version in place. Saving repeatedly from the same up-to-date
copy must keep working. Keep the schema unchanged.
