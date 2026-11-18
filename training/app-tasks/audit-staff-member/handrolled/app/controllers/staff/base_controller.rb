module Staff
  class BaseController < ApplicationController
    layout "staff"

    before_action :require_staff
    around_action :remember_staff_user
    helper_method :current_staff_user

    rescue_from Appointment::InvalidTransition, Invoice::NotPayable, Booking::Unavailable do |error|
      redirect_back fallback_location: staff_root_path, alert: error.message
    end

    private

    def remember_staff_user
      Thread.current[:mender_staff_user] = current_staff_user
      yield
    ensure
      Thread.current[:mender_staff_user] = nil
    end

    def current_staff_user
      @current_staff_user ||= StaffUser.find_by(id: session[:staff_user_id])
    end

    def require_staff
      redirect_to new_staff_session_path unless current_staff_user
    end

    def require_manager
      redirect_to staff_root_path, alert: "Managers only." unless current_staff_user.manager?
    end
  end
end
