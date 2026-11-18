View counts on popular stories come out too low. When two readers open a
story at the same moment, both requests read the same count and write back
count + 1, so one of the views is lost. Count every view. Counting a view
must not make the story look changed: its `updated_at`, and so the page's
ETag, stay as they were.
