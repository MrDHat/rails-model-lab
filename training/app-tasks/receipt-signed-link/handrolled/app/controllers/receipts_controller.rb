class ReceiptsController < ApplicationController
  def show
    id = Rails.application.message_verifier(:receipt).verified(params[:id])
    @order = Order.find_by(id: id) or raise ActiveRecord::RecordNotFound
  end
end
