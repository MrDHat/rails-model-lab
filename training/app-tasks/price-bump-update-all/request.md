Flour got dearer. Add `Product.raise_prices!(percent)`, which raises the
price of every active product by that percentage, rounded to the nearest
cent (140 raised by 7% is 150, 120 by 7% is 128), and leaves inactive
products alone. The catalogue has thousands of products, so it has to change
them all with one UPDATE statement rather than loading and saving each one,
and the changed products' `updated_at` moves to now (the API's product cache
depends on it). It returns the number of products it changed.
