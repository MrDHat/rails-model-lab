class TicketsController < ApplicationController
  def index
    render json: Ticket.order(:id)
  end

  def show
    render json: Ticket.find(params[:id])
  end

  def update
    ticket = Ticket.find(params[:id])
    if ticket.update(ticket_params)
      render json: ticket
    else
      render json: { errors: ticket.errors.to_hash }, status: :unprocessable_entity
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:title, :status, :team_id)
  end
end
