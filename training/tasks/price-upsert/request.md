PriceImport.call(rows) receives an array like [{ sku: 'A', cents: 100 }]. Insert
SKUs we don't have and update cents for SKUs we do, matching on sku. Feeds
have thousands of rows, so the import must be a single SQL write statement,
not one per row. Keep the schema unchanged.
