module Api
  class StockController < BaseController
    def create
      rows = params.expect(products: [%i[sku name price_cents stock]]).map do |row|
        { sku: row[:sku], name: row[:name], price_cents: Integer(row[:price_cents]), stock: Integer(row[:stock]), active: false }
      end
      Product.upsert_all(rows, unique_by: :sku, update_only: [:stock]) if rows.any?
      render json: { received: rows.size }
    end
  end
end
