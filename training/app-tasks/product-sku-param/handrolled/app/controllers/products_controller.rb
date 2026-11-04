class ProductsController < ApplicationController
  def index
    @products = Product.available.order(:name)
  end

  def show
    @product = Product.find_by!(sku: params[:id].upcase)
  end
end
