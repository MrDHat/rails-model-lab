Deleting a category that still has products leaves orphaned products. When a
category has products, category.destroy must return false, leave everything in
place, and put an error on the category's base errors for the admin screen
to show. It must not raise. Empty categories delete normally.
