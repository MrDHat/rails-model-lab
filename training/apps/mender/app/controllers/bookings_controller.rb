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
      redirect_to booking_path(@appointment), notice: "Your appointment has been cancelled."
    else
      redirect_to booking_path(@appointment), alert: "This appointment can no longer be cancelled."
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end
end
