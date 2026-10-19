class ExpenseClaimsController < ApplicationController
  def create
    claim = ExpenseClaim.new(claim_params)
    save_claim(claim, :created)
  end

  def update
    claim = ExpenseClaim.find(params[:id])
    claim.assign_attributes(claim_params)
    save_claim(claim, :ok)
  end

  def show
    render json: ExpenseClaim.find(params[:id])
  end

  private

  def claim_params
    params.require(:expense_claim).permit(:merchant, :amount_cents, :incurred_on, :status)
  end

  def save_claim(claim, success_status)
    if claim.save
      render json: claim, status: success_status
    else
      render json: { errors: claim.errors.to_hash }, status: :unprocessable_entity
    end
  end
end
