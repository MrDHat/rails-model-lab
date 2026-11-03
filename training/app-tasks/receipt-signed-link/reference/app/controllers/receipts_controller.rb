class ReceiptsController < ApplicationController
  def show
    @order = Order.find_signed(params[:id], purpose: :receipt) or raise ActiveRecord::RecordNotFound
  end
end
