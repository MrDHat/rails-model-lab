module Api
  class StockController < BaseController
    def create
      rows = params.expect(products: [%i[sku name price_cents stock]]).map do |row|
        { sku: row[:sku], name: row[:name], price_cents: Integer(row[:price_cents]), stock: Integer(row[:stock]), active: false }
      end
      if rows.any?
        now = Product.connection.quote(Time.current)
        values = rows.map { |r| "(#{r.values.map { Product.connection.quote(_1) }.join(", ")}, #{now}, #{now})" }
        Product.connection.exec_update(<<~SQL)
          INSERT INTO products (sku, name, price_cents, stock, active, created_at, updated_at) VALUES #{values.join(", ")}
          ON CONFLICT (sku) DO UPDATE SET stock = excluded.stock,
            updated_at = CASE WHEN products.stock = excluded.stock THEN products.updated_at ELSE excluded.updated_at END
        SQL
      end
      render json: { received: rows.size }
    end
  end
end
