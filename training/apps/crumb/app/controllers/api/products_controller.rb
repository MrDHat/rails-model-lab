module Api
  class ProductsController < BaseController
    def index
      render json: Product.available.order(:name).map(&:as_api)
    end

    def show
      render json: Product.find_by!(sku: params[:id]).as_api
    end
  end
end
