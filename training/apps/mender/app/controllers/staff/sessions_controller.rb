module Staff
  class SessionsController < BaseController
    skip_before_action :require_staff, only: %i[new create]

    def new
    end

    def create
      if (user = StaffUser.authenticate(params[:email], params[:access_code]))
        reset_session
        session[:staff_user_id] = user.id
        redirect_to staff_root_path
      else
        flash.now[:alert] = "Wrong email or access code."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      reset_session
      redirect_to new_staff_session_path
    end
  end
end
