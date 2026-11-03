module Api
  class ProductsController < BaseController
    def index
      products = Product.available.order(:name)
      key = ["api/products", products.cache_key_with_version]
      json = Rails.cache.read(key)
      unless json
        json = products.map(&:as_api).to_json
        Rails.cache.write(key, json, expires_in: 10.minutes)
      end
      render json: json
    end

    def show
      render json: Product.find_by!(sku: params[:id]).as_api
    end
  end
end
