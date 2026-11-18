# The page patients reach from the link in their confirmation email: see the
# booking and cancel it.
class BookingsController < ApplicationController
  before_action :set_appointment

  def show
  end

  def destroy
    if @appointment.booked?
      @appointment.cancel!(reason: "Cancelled from the email link")
      AppointmentMailer.cancellation(@appointment).deliver_later
      flash.now[:notice] = "Your appointment has been cancelled."
      render :show
    else
      redirect_to booking_path(@appointment), alert: "This appointment can no longer be cancelled."
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find_by_token_for(:manage, params[:id]) || raise(ActiveRecord::RecordNotFound)
  end
end
