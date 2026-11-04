module Api
  class ProductsController < BaseController
    def index
      products = Product.available.order(:name)
      render json: Rails.cache.fetch("api/products", expires_in: 10.minutes) { products.map(&:as_api).to_json }
    end

    def show
      render json: Product.find_by!(sku: params[:id]).as_api
    end
  end
end
