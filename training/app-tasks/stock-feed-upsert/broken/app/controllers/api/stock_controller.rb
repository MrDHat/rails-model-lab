module Api
  class StockController < BaseController
    def create
      rows = params.expect(products: [%i[sku name price_cents stock]]).map do |row|
        { sku: row[:sku], name: row[:name], price_cents: Integer(row[:price_cents]), stock: Integer(row[:stock]), active: false }
      end
      rows.each do |row|
        product = Product.find_or_initialize_by(sku: row[:sku])
        product.new_record? ? product.update!(row) : product.update!(stock: row[:stock])
      end
      render json: { received: rows.size }
    end
  end
end
